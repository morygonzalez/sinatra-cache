# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinatra/cache/version'

Gem::Specification.new do |spec|
  spec.name          = "sinatra-cache"
  spec.version       = Sinatra::Cache::VERSION
  spec.authors       = ["kematzy"]
  spec.email         = ["kematzy@gmail.com"]
  spec.description   = %q{A Sinatra Extension that makes Page and Fragment Caching easy.}
  spec.summary       = %q{A Sinatra Extension that makes Page and Fragment Caching easy.}
  spec.homepage      = "https://github.com/kematzy/sinatra-cache"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency(%q<sinatra>)
  spec.add_development_dependency(%q<rspec>)
  spec.add_development_dependency(%q<haml>)
  spec.add_development_dependency(%q<sass>)
  spec.add_development_dependency(%q<json>)
end
