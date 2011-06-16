# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "seh/version"

Gem::Specification.new do |s|
  s.name        = "seh"
  s.version     = Seh::VERSION
  s.authors     = ["Ryan Berckmans"]
  s.email       = ["ryan.berckmans@gmail.com"]
  s.homepage    = "https://github.com/ryanberckmans/seh"
  s.summary     = "pure ruby event handling similar to w3c dom events; pre-alpha wip"
  s.description = "Pure ruby event handling similar to w3c dom events. Lots of bells and whistles to support complex event handling as required by stuff like video games.
+ event handling in a synchronous specific order
+ event targets can have multiple parents and common ancestors; event propagation does a breadth first search traversal over a directed acyclic event target graph
+ staged callbacks: event.before { .. }; event.after { .. }
+ staged callbacks allow for an ancestor to influence affect of event on a descendant: ancestor.before { |event| event.x = 5 }; descendant.after { |event| puts event.x }
+ events can have multiple types, and types can inherit from other types
+ bind callbacks using event type filtering: node.bind(overcast AND (rain OR snow)) { |event| callback! }
+ optional event failure: event.success { yay! }; event.failure { oops! }
+ events on stack don't care about other events above/below - event A, currently executing, can create/dispatch/finish another event B"

  s.rubyforge_project = "seh"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
