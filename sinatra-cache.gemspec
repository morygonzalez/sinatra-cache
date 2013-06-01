# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinatra/cache/version'

Gem::Specification.new do |spec|
  spec.name          = "sinatra-cache"
  spec.version       = Sinatra::Cache::VERSION
  spec.authors       = ["kematzy","森井ゴンザレス"]
  spec.email         = ["kematzy@gmail.com", "morygonzalez@gmail.com"]
  spec.description   = %q{A Sinatra Extension that makes Page and Fragment Caching easy.}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = "https://github.com/morygonzalez/sinatra-cache"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency(%q<sinatra>, [">= 1.1.0"])
  spec.add_runtime_dependency(%q<sinatra-outputbuffer>, [">= 0.1.0"])
  spec.add_development_dependency(%q<sinatra-tests>, [">= 0.1.6"])
  spec.add_development_dependency(%q<rspec>, [">= 1.3.0"])
end
