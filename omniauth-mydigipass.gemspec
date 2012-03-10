# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-mydigipass/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nathan Van der Auwera"]
  gem.email         = ["nathan@dixis.com"]
  gem.summary       = %Q{OmniAuth strategy for MYDIGIPASS.COM}
  gem.description   = %Q{OmniAuth strategy for MYDIGIPASS.COM, which can be used for sandbox or production}
  gem.homepage      = "https://github.com/nathanvda/omniauth-mydigipass"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-mydigipass"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::Mydigipass::VERSION

  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_dependency 'omniauth-oauth2', '~> 1.0'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'simplecov'
end
