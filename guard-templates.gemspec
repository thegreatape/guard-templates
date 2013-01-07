# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
Gem::Specification.new do |s|
  s.name        = "guard-templates"
  s.version     = "0.0.2"
  s.authors     = ["Thomas Mayfield"]
  s.email       = ["Thomas.Mayfield@gmail.com"]
  s.homepage    = ""
  s.summary     = "Javascript template compilation via Guard"
  s.description = "Guard plugin for smart, automatic compilation of your Javascript template files into usable Javascript"

  s.rubyforge_project = "guard-templates"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_path = "lib"

  s.add_runtime_dependency "guard"
  s.add_runtime_dependency "execjs"
  s.add_runtime_dependency "json"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "fakefs"
end
