source 'https://rubygems.org'

# Include a bunch of language encoding settings.
LANG="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

gemspec

group :test do
  gem 'debugger2' unless RUBY_VERSION < "2.0"
  gem 'coveralls', require: false
  gem 'growl'
end

group :development do
  gem 'rspec', '~> 2.13'
  gem 'guard-rspec'
  gem 'rake'
end