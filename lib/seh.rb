require "seh/version"
require "seh/event_type"
require "seh/event_target"
require "seh/event"

module Seh
  class << self
    # @note alias of {EventType::And}
    def and( *types )
      EventType::And.new *types
    end

    # @note alias of {EventType::Or}
    def or( *types )
      EventType::Or.new *types
    end

    # @note alias of {EventType::Not}
    def not( type )
      EventType::Not.new type
    end
  end
end
