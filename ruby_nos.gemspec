gem_name = "ruby_nos"

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "#{gem_name}/version"

Gem::Specification.new do |spec|
  spec.name = gem_name
  spec.version = RubyNos::VERSION
  spec.authors = ["Workshare's dev team"]
  spec.email = ['_Development@workshare.com']
  spec.description = "A gem to provide microservices autodiscovery to Ruby microservices."
  spec.summary = "A gem to provide microservices autodiscovery to Ruby microservices. This gem allows a microservice to publish its existence on a cloud, store other microservices information and public its API."
  spec.homepage = "https://github.com/worshare/#{spec.name.gsub('_','-')}"
  spec.license = "Copyright"
  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.4"
end