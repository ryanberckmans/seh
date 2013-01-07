require 'seh'
require_relative "damage"
require_relative "hostile"

module Event
  class << self
    def melee_attack event, attacker, defender, attack_hit, attack_damage
      hostile event, attacker, defender

      event.target attacker, defender
      event.type :melee_attack

      event.attacker = attacker
      event.defender = defender
      event.attack_hit = attack_hit # true/false if this attack is currently hitting
      event.attack_damage = attack_damage # damage this attack will do if it hits

      event.add_stage :melee_determine_hit # an opportunity to affect the outcome of attack_hit
      event.add_stage :melee_miss do !event.attack_hit end # unless attack_hit, run melee_miss
      event.add_stage :melee_hit do event.attack_hit end # if attack_hit is true, run melee_hit

      event.finish do # when the melee_attack event is over, create a damage event if the attack hit
        next unless event.attack_hit
        damage_event = Seh::Event.new
        damage damage_event, event.attacker, event.defender, event.attack_damage
        damage_event.dispatch
      end

      event
    end
  end # class << self
end
