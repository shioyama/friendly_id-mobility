source 'https://rubygems.org'

# Specify your gem's dependencies in friendly_id-mobility.gemspec
gemspec

group :development, :test do
  gem 'rake'

  if ENV['RAILS_VERSION'] && ENV['RAILS_VERSION'] < '5.2'
    gem 'sqlite3', '~> 1.3.13'
  else
    gem 'sqlite3'
  end

  gem 'rails', "~> #{ENV['RAILS_VERSION'] || '6.0'}.0"

  gem 'pry'
  gem 'pry-byebug'
end
