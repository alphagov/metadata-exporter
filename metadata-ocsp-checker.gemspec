# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metadata/ocsp/checker/version'

Gem::Specification.new do |spec|
  spec.name          = "metadata-ocsp-checker"
  spec.version       = Metadata::Ocsp::Checker::VERSION
  spec.authors       = ["Christopher Holmes"]
  spec.email         = ["christopher.holmes@digital.cabinet-office.gov.uk"]
  spec.summary       = %q{A tool for verifying the status of certficates defined in SAML metadata}
  spec.description   = %q{A tool for verifying the status of certficates defined in SAML metadata}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "cucumber", "~> 2.0"
end
