require 'seh'



# mob.rb
class Mob
  include Seh::EventTarget
  
  attr_accessor :name, :hp
  def initialize( name )
    @name = name
    @hp = 100
  end
end

# event/damage.rb
DAMAGE_ADD = 10
DAMAGE_MULTIPLY = 20

# apply a templated damage event to the passed event
#
# @param event to apply damage event to
def damage( event, damager, receiver, damage )
  event.target damager, receiver
  event.type :damage

  event.damager = damager
  event.receiver = receiver
  event.damage = damage
  
  event.start { "damage started: #{damager.name} doing #{damage} to #{receiver.name}" }
  event.finish_success { receiver.hp -= event.damage }

  hostile event, damager, receiver
end

def hostile( event, aggressor, aggressee )
  event.target aggressor, aggressee
  event.type :hostile
  
  event.aggressor = aggressor
  event.aggressee = aggressee

  event.finish_success { puts "hostile: #{aggressor.name} succeeded a hostile action against #{aggressee.name}" }
  event.finish_failure { puts "hostile: #{aggressor.name} failed a hostile action against #{aggressee.name}" }
end

def run
  fred = Mob.new "fred"
  jim  = Mob.new "jim"

  # fred hits jim for 10
  Seh::Event.new { damage self, fred, jim, 10 }
end

run if $0 == __FILE__
