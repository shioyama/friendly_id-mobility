source 'https://rubygems.org'

# Specify your gem's dependencies in friendly_id-mobility.gemspec
gemspec

group :development, :test do
  gem 'rake'

  gem 'sqlite3'

  if ENV['RAILS_VERSION'] == '5.1'
    gem 'rails', '>= 5.1', '< 5.2'
  elsif ENV['RAILS_VERSION'] == '5.0'
    gem 'rails', '>= 5.0', '< 5.1'
  else
    gem 'rails', '>= 5.2.0.rc2', '< 5.3'
  end

  gem 'pry'
  gem 'pry-byebug'
end
