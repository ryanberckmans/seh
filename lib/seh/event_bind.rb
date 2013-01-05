require_relative 'event_type'

module Seh
  # @private
  # Internal use only. Container for an event_type,block pair bound to an EventTarget. Converts event_type into a Seh::EventType
  class EventBind
    attr_reader :event_type, :block
    
    def initialize event_type, &block
      event_type = EventType.new event_type unless event_type.is_a? EventType
      @event_type = event_type
      @block = block
    end
  end
end
