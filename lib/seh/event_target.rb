require_relative 'event_bind'
require_relative 'event_bind_disconnector'

module Seh
  module EventTarget
    def bind event_type=nil, &block
      raise "expected a block" unless block_given?
      @_binds ||= []
      bind = EventBind.new event_type, &block
      @_binds << bind
      EventBindDisconnector.new ->{ @_binds.delete bind; nil }
    end

    def bind_once event_type=nil, &block
      return unless block_given?
      bind_disconnector = self.bind(event_type) { |event| bind_disconnector.disconnect; block.call event }
    end

    # @private
    # Internal use only. Used in Seh::Event.
    # Override #observers as needed.
    # @return [EventTarget] - array of other EventTargets observing this EventTarget
    def observers
      []
    end

    # @private
    # Internal use only. Used in Seh::Event.
    # For each bind matching the passed event_types, yield the bind's callback
    # @param event_types - Array of event types
    # @yield each bind callback matching the passed event types
    # @return nil
    def each_matching_callback event_types
      @_binds ||= []
      @_binds.each { |bind| yield bind.block if bind.event_type.match event_types }
      nil
    end

    # An empty class that includes EventTarget
    class Default
      include EventTarget
    end
  end
end
