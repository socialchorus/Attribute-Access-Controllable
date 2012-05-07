# -*- encoding: utf-8 -*-
require File.expand_path('../lib/attribute_access_controllable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Social Chorus", "Kenneth Mayer"]
  gem.email         = ["tech@socialchorus.com", "kmayer@bitwrangler.com"]
  gem.description   = %q{Allow attribute-level read/write access control, per instance, of any ActiveModel class.}
  gem.summary       = <<'EOT'
This gem allows you to control write access at the _attribute_ level, on a 
per-instance basis. For example, let's say you had a model `Person` that has 
an attribute, `birthday`, which, for security purposes, once this attribute is 
set, cannot be changed again (except, perhaps by an administrator with 
extraordinary privileges). Any attempts to change this value to 
raise a validation error.
EOT
  gem.homepage      = "https://github.com/halogenguides/Attribute-Access-Controllable"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "attribute_access_controllable"
  gem.require_paths = ["lib"]
  gem.version       = AttributeAccessControllable::VERSION
  
  gem.add_runtime_dependency('activesupport', ['~> 3.2.1'])
  gem.add_runtime_dependency('activemodel',   ['~> 3.2.1'])
  gem.add_runtime_dependency('railties',      ['~> 3.2.1'])
  
  gem.add_development_dependency('rspec', ['~> 2.8.0'])
  gem.add_development_dependency('pivotal_git_scripts')
  gem.add_development_dependency('informal')
  gem.add_development_dependency('activerecord')
  gem.add_development_dependency('aruba')
  gem.add_development_dependency('ammeter')
end
