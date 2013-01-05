require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "run a simple Seh benchmark"
task :benchmark do
  $:.unshift File.expand_path(File.dirname(__FILE__) + "/examples")
  require 'seh'
  require_relative 'examples/mob'
  require_relative 'examples/event/damage'

  bob = Mob.new
  fred = Mob.new

  damage_shield = Seh::EventTarget::Default.new
  damage_shield.bind(:damage) { |event| event.start { event.damage_add -= 0 } }
  bob.observers << damage_shield

  fred.bind(:hostile) { "oh no, hostile on fred" }
  
  start_time = Time.now
  10000.times do
    e = Seh::Event.new
    Event::damage e, bob, fred, 0
    e.dispatch
  end
  puts "took: #{Time.now - start_time}"
end
