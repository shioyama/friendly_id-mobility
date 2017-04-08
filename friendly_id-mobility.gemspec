# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'friendly_id/mobility/version'

Gem::Specification.new do |spec|
  spec.name          = "friendly_id-mobility"
  spec.version       = FriendlyId::Mobility::VERSION
  spec.authors       = ["Chris Salzberg"]
  spec.email         = ["chris@dejimata.com"]

  spec.summary       = %q{Translate your FriendlyId slugs with Mobility.}
  spec.homepage      = "https://github.com/shioyama/friendly_id-mobility"
  spec.license       = "MIT"

  spec.files        = Dir['{lib/**/*,[A-Z]*}']
  spec.require_paths = ["lib"]

  spec.add_dependency 'mobility',    '~> 0.1.12'
  spec.add_dependency 'friendly_id', '>= 5.0.0', '<= 5.3.0'
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "database_cleaner", '~> 1.5.3'
end
