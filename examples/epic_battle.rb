#!/usr/bin/env ruby

require 'seh'
require_relative "event"

# An observer which reports on the battle. BenevolentOverlord sees each event affecting any Combatant due to Combatant#observers
class BenevolentOverlord
  include Seh::EventTarget
  def initialize
    melee_battle_damage_callbacks
    melee_battle_hostile_callbacks
    melee_battle_melee_attack_callbacks
  end

  def melee_battle_melee_attack_callbacks
    bind :melee_attack do |event|
      event.bind :melee_miss do
        puts "#{event.attacker}'s hit misses #{event.defender}. (event id #{event.object_id})"
      end
      
      event.bind :melee_hit do
        puts "#{event.attacker} successfully hits #{event.defender} for an initial damage of #{event.attack_damage}! (event id #{event.object_id})"
      end
    end
  end

  def melee_battle_damage_callbacks
    bind :damage do |event|
      event.start { puts "#{event.damager} tries to do #{event.damage} damage to #{event.receiver} (event id #{event.object_id})" }
      event.finish { puts "#{event.damager} did #{event.damage > 0 ? event.damage : 0} damage to #{event.receiver} (event id #{event.object_id})" }
    end
  end

  def melee_battle_hostile_callbacks
    bind :hostile do |event|
      # event.start { puts "hostile start: #{event.aggressor} on #{event.aggressee} (event id #{event.object_id})" }
      # event.finish { puts "hostile finish: #{event.aggressor} on #{event.aggressee} (event id #{event.object_id})" }
    end
  end

  INSTANCE = BenevolentOverlord.new
end

class Combatant
  include Seh::EventTarget
  
  attr_accessor :name, :hp, :affects
  def initialize name
    @name = name
    @hp = 50
    @affects = {}
  end

  def observers
    [BenevolentOverlord::INSTANCE]
  end

  def to_s
    @name
  end
end

def coin_flip
  Random.rand(2) > 0
end

def roll_damage
  Random.rand(40) + 1
end

class CombatantDied < Exception
  attr_reader :combatant
  def initialize combatant
    @combatant = combatant
  end
end

def melee_attack attacker, defender
  melee_attack_event = Seh::Event.new
  Event::melee_attack melee_attack_event, attacker, defender, coin_flip, roll_damage
  melee_attack_event.dispatch
  raise CombatantDied, attacker if attacker.hp < 1
  raise CombatantDied, defender if defender.hp < 1
end

############################
# rpg/effects.rb

# grant combatant the ability to dodge melee attacks
def dodge combatant
  puts "#{combatant} gains the ability to dodge"
  combatant.bind :melee_attack do |event|
    event.bind :melee_determine_hit do
      if event.defender == combatant && event.attack_hit && coin_flip
        event.attack_hit = false
        event.abort
        puts "#{event.attacker} tries to hit #{event.defender}, who dodges! (event id #{event.object_id})"
      end
    end
  end
end

# grant combatant the ability to riposte, i.e. to block and counterattack a melee attack
def riposte combatant
  puts "#{combatant} gains the ability to riposte"
  combatant.bind :melee_attack do |event|
    event.bind :melee_determine_hit do
      if event.defender == combatant && event.attack_hit && coin_flip && coin_flip
        event.attack_hit = false
        event.abort
        puts "#{event.attacker} attacks #{event.defender}, who parries and responds with a lightning-fast riposte! (event id #{event.object_id})"
        melee_attack event.defender, event.attacker
      end
    end
  end
end

# reduce incoming damage
SHIELD_AMOUNT = 12
def shield_of_the_ancients combatant
  return if combatant.affects.key? :shield_of_ancients
  puts "#{combatant} casts shield of the ancients"
  combatant.affects[:shield_of_ancients] = combatant.bind(:damage) do |event|
    event.bind :damage_modify do
      next unless event.receiver == combatant
      event.damage_reduction += SHIELD_AMOUNT
      puts "#{combatant}'s shield of the ancients reduces his damage taken by #{SHIELD_AMOUNT} (event id #{event.object_id})"
    end
  end
end

# for one damage event, reverse the damage back to the damager
def reflexive_barrier combatant
  return if combatant.affects.key? :reflexive_barrier
  puts "#{combatant} casts reflexive barrier"
  combatant.affects[:reflexive_barrier] = combatant.bind(:damage) do |event|
    event.bind :damage_targets do
      next unless event.receiver == combatant
      temp = event.damager
      event.damager = event.receiver
      event.receiver = temp
      puts "#{combatant} uses his reflexive barrier to reflect damage back at #{event.receiver} (event id #{event.object_id})"
      combatant.affects[:reflexive_barrier].disconnect
      combatant.affects.delete :reflexive_barrier
    end
  end
end

# disable the next hostile action when the aggressee is the combatant
def serenity combatant
  return if combatant.affects.key? :serenity
  puts "#{combatant}: casting serenity"
  combatant.affects[:serenity] = combatant.bind :hostile do |event|
    next unless event.aggressee == combatant
    event.abort 
    puts "#{combatant}'s serenity prevents hostile action by #{event.aggressor}"
    combatant.affects[:serenity].disconnect
    combatant.affects.delete :serenity
  end
end

def permanent_affects combatant
  shield_of_the_ancients combatant if coin_flip
  dodge combatant if coin_flip
  riposte combatant if coin_flip
end

def onetime_affects combatant
  reflexive_barrier combatant if coin_flip && coin_flip && coin_flip
  serenity combatant if coin_flip && coin_flip && coin_flip
end

############################
# put example all together

def run
  def status *combatants
    s = ''
    combatants.each { |m| s += m.to_s + ": " + m.hp.to_s + 'hp; ' }
    puts s
  end

  2.times do
    fred = Combatant.new "Fred"
    jim  = Combatant.new "Jim"
    puts "#{fred} and #{jim} rush into furious combat!"

    permanent_affects fred
    permanent_affects jim

    begin
      status fred, jim

      onetime_affects fred
      onetime_affects jim
      
      if coin_flip
        first = fred
        second = jim
      else
        first = jim
        second = fred
      end
      
      melee_attack first, second
      melee_attack second, first
      melee_attack first, second if coin_flip
      melee_attack second, first if coin_flip
    rescue CombatantDied => died
      puts "#{died.combatant} died!\n\n"
      break
    end while true
    puts "Myerael, arch-angel of battle, reincarnates #{fred} and #{jim}.."
  end
  puts "..and promptly slays them. The end."
end

run if $0 == __FILE__
