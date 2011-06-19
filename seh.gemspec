# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "seh/version"

Gem::Specification.new do |s|
  s.name        = "seh"
  s.version     = Seh::VERSION
  s.authors     = ["Ryan Berckmans"]
  s.email       = ["ryan.berckmans@gmail.com"]
  s.homepage    = "https://github.com/ryanberckmans/seh"
  s.summary     = "Structured event handler. Pure ruby event handling similar to w3c dom events; alpha wip."
  s.description = "#{s.summary} Lots of bells and whistles to support complex event handling as required by stuff like video games. Event handling in a synchronous specific order. Events 'bubble', and event targets can have multiple parents and common ancestors. Staged event callbacks: event.before { "the united states of" }; event.after { "america" }. Staged callbacks allow an ancestor to influence affect of event on a descendant: ancestor.before { |event| event.damage *= 2 }; descendant.after { |event| player.health -= event.damage }. Events use 'tag-style' types: event.type :hostile ; event.type :spell. Handle only events which pass a filter: player.bind( Seh::and :hostile, Seh::not( :spell ) ) { |event| 'Hostile non-spell!!' }. Optional event failure: event.fail; event.success { 'yay!' }; event.failure { 'oops!' }. Event inherits from OpenStruct for dynamic properties: event.omgs = 'omgs a dynamic attribute'"

  s.rubyforge_project = "seh"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options << '--title' << 'seh - structured event handling' \
                 << '--main'  << 'README.org'
  s.extra_rdoc_files = ['README.org']
end
