# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'guard/guard-templates/version'

Gem::Specification.new do |s|
  s.name        = "guard-templates"
  s.version     = "0.0.1"
  s.authors     = ["Thomas Mayfield"]
  s.email       = ["Thomas.Mayfield@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "guard-templates"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "guard"
  s.add_runtime_dependency "execjs"
  s.add_runtime_dependency "json"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "fakefs"
end
