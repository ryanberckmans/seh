require "seh"
require_relative "hostile"

module Event
  class << self
    def damage( event, damager, receiver, base_damage )
      hostile event, damager, receiver
      
      event.target damager, receiver
      event.type :damage
      event.damager = damager
      event.receiver = receiver
      event.base_damage = base_damage
      event.damage = base_damage
      
      event.add_stage :damage_add, :start
      event.add_stage :damage_multiply, :damage_add
      event.add_stage :damage_apply, :damage_multiply

      begin
        event.add_stage :should_raise, :does_not_exist
      rescue Seh::Event::StageNotFoundError => stage_not_found
      end

      event.damage_apply { event.receiver.hp -= event.damage }
      nil
    end
  end
end
