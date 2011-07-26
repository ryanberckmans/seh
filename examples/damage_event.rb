#!/usr/bin/env ruby

require 'seh'

############################
# mob.rb

class Mob
  include Seh::EventTarget
  
  attr_accessor :name, :hp
  def initialize( name )
    @name = name
    @hp = 100
  end
end

############################
# event/damage.rb

DAMAGE_ADD = 10
DAMAGE_MULTIPLY = 20
DAMAGE_LOCKED = 30

# apply a templated damage event to the passed event
#
# @param event to apply damage event to
def damage( event, dealer, receiver, damage )
  damage_properties event, dealer, receiver, damage
  damage_handlers event
  hostile event, dealer, receiver
end

# private
def damage_properties( event, dealer, receiver, damage )
  event.target dealer, receiver
  event.type :damage

  event.dealer = dealer
  event.receiver = receiver
  event.damage = damage
end

def damage_handlers( event )
  event.start { puts "damage started: #{event.dealer.name} doing #{event.damage} to #{event.receiver.name}" }
  event.finish_success { event.receiver.hp -= event.damage; puts "damage finish success: #{event.dealer.name} did #{event.damage} to #{event.receiver.name}" }
  event.finish_failure { puts "damage finish fail: #{event.dealer.name} failed to do #{event.damage} to #{event.receiver.name}" }
end

############################
# event/hostile.rb

def hostile( event, aggressor, aggressee )
  hostile_properties event, aggressor, aggressee
  hostile_handlers event
end

def hostile_properties( event, aggressor, aggressee )
  event.target aggressor, aggressee
  event.type :hostile
  
  event.aggressor = aggressor
  event.aggressee = aggressee
end

def hostile_handlers( event )
  event.start { puts "hostile start: #{aggressor.name} on #{aggressee.name}" }
  event.finish_success { puts "hostile finish success: #{aggressor.name} on #{aggressee.name}" }
  event.finish_failure { puts "hostile finish fail: #{aggressor.name} on #{aggressee.name}" }
end

############################
# rpg/effects.rb

# reduce incoming damage by 3
def shield_of_the_ancients( mob )
  puts "#{mob.name}: casting shield of the ancients"
  mob.bind(:damage) { |event| event.bind(DAMAGE_ADD) { event.damage -= 3; puts "shield of the ancients (#{mob.name}): damage reduced to #{event.damage}" } }
end

# for one damage event, reverse the damage back to the dealer
def reflexive_barrier(mob)
  puts "#{mob.name}: casting reflexive barrier"
  mob.bind_once(:damage) { |event| event.start { temp = event.dealer; event.dealer = event.receiver; event.receiver = temp; puts "reflexive barrier (#{mob.name}): damage reflected back at #{event.receiver.name}" } }
end

# disable hostile action to or from mob
def serenity(mob)
  puts "#{mob.name}: casting serenity"
  mob.bind(:hostile) { |event| event.fail; puts "serenity (#{mob.name}): preventing hostile action by #{event.aggressor.name} on #{event.aggressee.name}" }
end

############################
# put example all together

def run
  def status( *mobs )
    s = ''
    mobs.each { |m| s += m.name + ": " + m.hp.to_s + 'hp; ' }
    puts s
  end
  
  fred = Mob.new "fred"
  jim  = Mob.new "jim"

  status fred, jim
  
  # fred hits jim for 20
  Seh::Event.new { damage self, fred, jim, 20 }

  status fred, jim
  puts "-----"

  # fred acquires the shield of the ancients
  shield_of_the_ancients fred

  # jim hits fred for 20; reduced to 17 by shield of the ancients
  Seh::Event.new { damage self, jim, fred, 20 }

  status fred, jim
  puts "-----"

  # jim casts reflexive barrier
  reflexive_barrier jim

  # fred hits jim for 15, rebounds to fred due to jim's reflexive barrier, then reduced by 3 due to fred's shield of the ancients, 12 final damage to fred
  Seh::Event.new { damage self, fred, jim, 15 }

  status fred, jim
  puts "-----"
  
  # fred casts serenity
  serenity fred

  # jim hits fred for 50, cancelled by fred's serenity
  Seh::Event.new { damage self, jim, fred, 50 }

  status fred, jim
  puts "-----"
  
  # fred hits jim for 30, also cancelled by fred's serenity
  Seh::Event.new { damage self, fred, jim, 30 }

  status fred, jim
  puts "-----"

  puts "done"
end

run if $0 == __FILE__
