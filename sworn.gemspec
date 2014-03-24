# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sworn/version'

Gem::Specification.new do |spec|
  spec.name          = "sworn"
  spec.version       = Sworn::VERSION
  spec.authors       = ["Martin Svangren"]
  spec.email         = ["martin@masv.net"]
  spec.description   = %q{Sworn is Rack middleware to handle OAuth 1.0a signed requests}
  spec.summary       = %q{Rack middleware for OAuth 1.0a signed requests}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "simple_oauth"
end
