require "seh/version"
require "seh/event_type"
require "seh/event_target"
require "seh/event"

module Seh
  class << self
    def and( *types )
      EventType::And.new *types
    end

    def or( *types )
      EventType::Or.new *types
    end

    def not( type )
      EventType::Not.new type
    end
  end
end
