# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/zcloudjp_version.rb'

Gem::Specification.new do |spec|
  spec.name          = "kitchen-zcloudjp"
  spec.version       = Kitchen::Driver::ZCLOUDJP_VERSION
  spec.authors       = ["sawanoboly"]
  spec.email         = ["sawanoboriyu@higanworks.com"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "Apache2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "test-kitchen", "~> 1.0.0.alpha"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
