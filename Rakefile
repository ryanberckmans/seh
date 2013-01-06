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

  def test name
    start_time = Time.now
    500000.times do
      yield
    end
    elapsed = Time.now - start_time
    puts "#{name.to_s} took: #{elapsed}"
    elapsed
  end

  def setup bob, fred
    damage_shield = Seh::EventTarget::Default.new
    damage_shield.bind(:damage) { |event| event.start { event.damage_add -= 0 } }
    bob.observers << damage_shield
    
    fred.bind(:hostile) { "oh no, hostile on fred" }
  end

  bob = Mob.new
  fred = Mob.new

  setup bob, fred

  no_template_time_elapsed = test "no template" do
    e = Seh::Event.new
    Event::damage e, bob, fred, 0
    e.dispatch
  end

  bob = Mob.new
  fred = Mob.new

  setup bob, fred

  with_template_time_elapsed = test "with template" do
    e = Seh::Event.new Event::DAMAGE_TEMPLATE
    Event::damage_with_template e, bob, fred, 0
    e.dispatch
  end

  puts "template time savings: #{100 - 100.0 * with_template_time_elapsed / no_template_time_elapsed}%"
end
