require "seh"
require_relative "hostile"

module Event
  class << self
    def damage event, damager, receiver, damage
      hostile event, damager, receiver
      
      event.target damager, receiver
      event.type :damage
      event.damager = damager
      event.receiver = receiver
      
      event.damage = damage
      event.damage_add = 0 # bonus damage
      event.damage_multiply = 1.0 # % bonus damage and stacks with damage_add
      event.damage_reduction = 0 # directly subtracted from semifinal damage

      event.add_stage :damage_targets # use stage to modify event.damager/receiver
      event.add_stage :damage_modify # use stage to modify event.damage_add, damage_multiply, damage_reduction
      event.add_stage :damage_apply # damage is applied during this stage, do not interfere

      event.bind :damage_apply do
        final_damage = ((event.damage + event.damage_add) * event.damage_multiply - event.damage_reduction).round
        event.receiver.hp -= final_damage if final_damage > 0 # as a design decision, don't allow negative damage to heal
        event.damage = final_damage
      end
      event
    end
  end
end
