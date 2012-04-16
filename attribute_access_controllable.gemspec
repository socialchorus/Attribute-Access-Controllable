# -*- encoding: utf-8 -*-
require File.expand_path('../lib/attribute_access_controllable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Social Chorus", "Kenneth Mayer"]
  gem.email         = ["tech@socialchorus.com", "kmayer@bitwrangler.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "attribute_access_controllable"
  gem.require_paths = ["lib"]
  gem.version       = AttributeAccessControllable::VERSION
  
  gem.add_runtime_dependency('activesupport', ['~> 3.2.1'])
  gem.add_runtime_dependency('activemodel',   ['~> 3.2.1'])
  
  gem.add_development_dependency('rspec', ['~> 2.8.0'])
  gem.add_development_dependency('pivotal_git_scripts')
  gem.add_development_dependency('informal')
  gem.add_development_dependency('activerecord')
end
