# encoding=utf-8
require 'spec_helper'

describe Polytexnic::Pipeline do

  before(:all) do
    FileUtils.rm('.highlight_cache') if File.exist?('.highlight_cache')
  end

  describe '#to_latex' do
    subject(:processed_text) { Polytexnic::Pipeline.new(polytex).to_latex }

    describe "for vanilla LaTeX" do
      let(:polytex) { '\emph{foo}' }
      it { should include(polytex) }
    end

    describe "with source code highlighting" do
      let(:polytex) do <<-'EOS'
%= lang:ruby
\begin{code}
def hello
  "hello, world!"
end
\end{code}

Make a code listing as in Listing~\ref{code:hello}.

\begin{codelisting}
\label{code:hello}
\codecaption{A hello program in Ruby.}
%= lang:ruby
\begin{code}
def hello
  "hello, world!"
end
\end{code}
\end{codelisting}

        \noindent lorem ipsum
      EOS
      end

      it { should resemble '\begin{framed_shaded}' + "\n" }
      it { should resemble "\n" + '\end{framed_shaded}' }
      it { should_not resemble "\n" + '\end{framed_shaded})' }
      it { should resemble "commandchars=\\\\\\{" }
      it { should resemble '\begin{Verbatim}' }
      it { should resemble 'commandchars' }
      it { should resemble '\end{Verbatim}' }
      it { should_not resemble 'def hello' }
      it { should resemble '\noindent lorem ipsum' }

      describe "in the middle of a line" do
        let(:polytex) { 'Use \verb+%= lang:ruby+ to highlight Ruby code' }
        it { should resemble '\verb' }
        it { should_not resemble '<div class="highlight">' }
      end
    end

    context "with the metacode environment" do
      let(:polytex) do <<-'EOS'
        %= lang:latex
        \begin{metacode}
        %= lang:ruby
        \begin{code}
        def foo
          "bar"
        end
        \end{code}
        \end{metacode}

        \noindent lorem ipsum
        EOS
      end

      it { should resemble '\begin{framed_shaded}' + "\n" }
      it { should resemble "\n" + '\end{framed_shaded}' }
      it { should resemble "commandchars=\\\\\\{" }
      it { should_not resemble '%= lang:ruby' }
    end

    describe "Verbatim environments" do
      let(:polytex) do <<-'EOS'
        \begin{verbatim}
        def foo
          "bar"
        end
        \end{verbatim}

        \begin{Verbatim}
        def foo
          "bar"
        end
        \end{Verbatim}

        \begin{Verbatim}
          x
        \end{equation}
        \end{Verbatim}
        EOS
      end

      it { should resemble polytex }

      context "containing an example of highlighted code" do
        let(:polytex) do <<-'EOS'
          \begin{verbatim}
          %= lang:ruby
          def foo
            "bar"
          end
          \end{verbatim}
          EOS
        end

        it { should resemble polytex }
      end

      context "with an equation" do
        let(:polytex) do <<-'EOS'
          \begin{equation}
          \label{eq:x_y}
          x_y
          \end{equation}
          EOS
        end

        it { should resemble polytex }
        it { should_not resemble 'xmlelement' }
        it { should_not resemble 'xbox' }
        it "should have only one '\end{equation}'" do
          n_ends = processed_text.scan(/\\end{equation}/).length
          expect(n_ends).to eq 1
        end
      end

      context "with code from Urbit docs that broke things" do
        let(:polytex) do <<-'EOS'
          \begin{verbatim}
          ~waclux-tomwyc/try=> 'Foo \'bar'
          \end{verbatim}
          EOS
        end

        it { should include "'Foo \\'bar'" }
      end
    end

    describe "hyperref links" do
      let(:polytex) do <<-'EOS'
        Chapter~\ref{cha:foo}
        EOS
      end
      let(:output) { '\hyperref[cha:foo]{Chapter~\ref{cha:foo}' }
      it { should resemble output }
    end

    describe "asides" do

      context "with headings and labels" do
        let(:polytex) do <<-'EOS'
          \begin{aside}
          \label{aside:foo}
          \heading{Foo \emph{are} bar.}

          lorem ipsum

          \end{aside}
          EOS
        end

        let(:output) do <<-'EOS'
          \begin{shaded_aside}{Foo \emph{are} bar.}{aside:foo}

          lorem ipsum

          \end{shaded_aside}
          EOS
        end

        it { should resemble output }
      end
    end

    describe "tables" do

      let(:polytex) do <<-'EOS'
        \begin{table}
        lorem ipsum
        \end{table}
        EOS
      end

      let(:output) do <<-'EOS'
        \begin{table}
        \begin{center}
        \small
        lorem ipsum
        \end{center}
        \end{table}
        EOS
      end

      it { should resemble output }
    end

    describe "images with GIFs" do
      let(:polytex) do <<-'EOS'
        \includegraphics{foo.gif}
        \image{bar.gif}
        \imagebox{baz.gif}
        EOS
      end

      it { should include '\includegraphics{foo.png}' }
      it { should include '\image{bar.png}' }
      it { should include '\imagebox{baz.png}' }
    end
  end
end