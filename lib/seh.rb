require "seh/version"
require "seh/event_type"
require "seh/event_target"
require "seh/event"

module Seh
  class << self
    # alias for Seh::EventType::And
    def and( *types )
      EventType::And.new *types
    end

    # alias for Seh::EventType::Or
    def or( *types )
      EventType::Or.new *types
    end

    # alias for Seh::EventType::Not
    def not( type )
      EventType::Not.new type
    end
  end
end
