# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'valicuit/version'

Gem::Specification.new do |s|
  s.name        = 'valicuit'
  s.version     = Valicuit::VERSION
  s.authors     = ['Lautaro Nahuel De León']
  s.email       = ['laudleon@gmail.com', 'ldeleon@cespi.unlp.edu.ar']
  s.homepage    = 'http://github.com/lndl/valicuit'
  s.summary     = %q{A CUIT/CUIL validator for ActiveModel & Rails}
  s.description = %q{A CUIT/CUIL validator for ActiveModel & Rails with multiple customizable options}
  s.licenses    = ['MIT']

  s.add_runtime_dependency 'activemodel', '~> 5.2'

  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'simplecov', '~> 0.13'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0.9'
	
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
end
