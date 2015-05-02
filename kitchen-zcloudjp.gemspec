# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/zcloudjp_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-zcloudjp'
  spec.version       = Kitchen::Driver::ZCLOUDJP_VERSION
  spec.authors       = ['sawanoboly']
  spec.email         = ['sawanoboriyu@higanworks.com']
  spec.description   = %q{A Test Kitchen Driver for Zcloudjp}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/higanworks/kitchen-zcloudjp'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen', '~> 1.4.0'
  spec.add_dependency 'zcloudjp'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'tailor'
  spec.add_development_dependency 'countloc'
end
