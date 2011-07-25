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
  event.target dealer, receiver
  event.type :damage

  event.dealer = dealer
  event.receiver = receiver
  event.damage = damage
  
  event.start { "damage started: #{dealer.name} doing #{damage} to #{receiver.name}" }
  event.finish_success { receiver.hp -= event.damage }

  hostile event, dealer, receiver
end

############################
# event/hostile.rb

def hostile( event, aggressor, aggressee )
  event.target aggressor, aggressee
  event.type :hostile
  
  event.aggressor = aggressor
  event.aggressee = aggressee

  event.finish_success { puts "hostile: #{aggressor.name} succeeded a hostile action against #{aggressee.name}" }
  event.finish_failure { puts "hostile: #{aggressor.name} failed a hostile action against #{aggressee.name}" }
end


############################
# rpg/effects.rb

# reduce incoming damage by 3
def shield_of_the_ancients( mob )
  mob.bind(:damage) { |event| event.bind(DAMAGE_ADD) { event.damage -= 3; puts "shield of ancients: damage to #{event.receiver} reduced to #{event.damage}" } }
end

# for one damage event, reverse the damage back to the dealer
def reflexive_barrier(mob)
  mob.bind_once(:damage) { |event| event.start { temp = event.dealer; event.dealer = event.receiver; event.receiver = temp; puts "reflexive barrier: damage reflected back at #{event.receiver}" } }
end

def serenity(mob)
  mob.bind(:hostile) { |event| event.fail; puts "serenity: preventing hostile action by #{event.aggressor} on #{event.aggressee}" }
end

############################
# put example all together

def run
  fred = Mob.new "fred"
  jim  = Mob.new "jim"

  # fred hits jim for 10
  Seh::Event.new { damage self, fred, jim, 10 }

  # fred acquires the shield of the ancients
  shield_of_the_ancients fred

  # jim hits fred for 20; reduced to 17 by shield of the ancients
  Seh::Event.new { damage self, jim, fred, 20 }

  # jim casts reflexive barrier
  reflexive_barrier jim

  # fred hits jim for 15, rebounds to fred due to jim's reflexive barrier, then reduced by 3 due to fred's shield of the ancients, 12 final damage to fred
  Seh::Event.new { damage self, fred, jim, 15 }

  # fred casts serenity
  serenity fred

  # jim hits fred for 50, cancelled by fred's serenity
  Seh::Event.new { damage self, jim, fred, 50 }

  # fred hits jim for 30, also cancelled by fred's serenity
  Seh::Event.new { damage self, fred, jim, 30 }

  puts "done"
end

run if $0 == __FILE__
