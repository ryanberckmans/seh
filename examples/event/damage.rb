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
      event.damage_add = 0
      event.damage_multiply = 1.0
      
      event.add_stage :damage_add
      event.add_stage :damage_multiply
      event.add_stage :damage_apply

      event.bind(:damage_add) { event.damage += event.damage_add }
      event.bind(:damage_multiply) { event.damage *= event.damage_multiply }
      event.bind(:damage_apply) { event.receiver.hp -= event.damage if event.damage > 0 }
      nil
    end
  end
end
