# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openssl/win/root/version'

Gem::Specification.new do |spec|
  spec.name          = "openssl-win-root"
  spec.version       = OpenSSL::Win::Root::VERSION
  spec.authors       = ["Stas Ukolov"]
  spec.email         = ["ukoloff@gmail.com"]
  spec.description   = 'Fetch Root CA certificates from Windows system store'
  spec.summary       = ''
  spec.homepage      = "https://github.com/ukoloff/openssl-win-root"
  spec.license       = "MIT"

  spec.files         = Dir[*%w(lib ext).map{|s| "#{s}/**/*"}] << 'Gemfile'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extensions    = []

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "appveyor-worker"
end
