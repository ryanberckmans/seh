require 'seh'
require_relative "damage"
require_relative "hostile"

module Event
  def melee_attempt( event, attacker, defender )
    hostile event
    
    event.target attacker, defender
    event.type :melee_attempt
    event.attacker = attacker
    event.defender = defender
  end

  def melee_hit( event, attacker, defender )
    damage event
    
    event.target attacker, defender
    event.type :melee_hit
    event.attacker = attacker
    event.defender = defender
  end

  def melee_miss( event, attacker, defender )
    hostile event
    
    event.target attacker, defender
    event.type :melee_miss
    event.attacker = attacker
    event.defender = defender    
  end
  
  def melee( attacker, defender )
    melee_attempt_event = Seh::Event.new { melee_attempt self, attacker, defender }
    return if melee_attempt_event.aborted?
    Random.new.rand(0..2) < 1 ? melee_miss( attacker, defender) : melee_hit( attacker, defender)
  end

  def dodge( mob )
    mob.bind(:melee_hit) do |event|
      if not event.aborted? and Random.new.rand(0..3) < 1
        event.abort!
        event.abort { "you dodge the attack" }
      end
    end
  end

  def parry( mob )
    mob.bind(:melee_hit) do |event|
      if not event.aborted? and Random.new.rand(0..4) < 1
        event.abort!
        event.abort { "you parry the attack" }
      end
    end
  end
end
