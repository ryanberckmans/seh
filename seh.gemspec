# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "seh/version"

Gem::Specification.new do |s|
  s.name        = "seh"
  s.version     = Seh::VERSION
  s.authors     = ["Ryan Berckmans"]
  s.email       = ["ryan.berckmans@gmail.com"]
  s.homepage    = "https://github.com/ryanberckmans/seh"
  s.summary     = "event handling similar to w3c dom events; pre-alpha wip"
  s.description = ""

  s.rubyforge_project = "seh"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
