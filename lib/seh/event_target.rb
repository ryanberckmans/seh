module Seh
  module EventTarget
    def bind( event_type, &block )
      return unless block
      @_binds ||= []
      @_binds << Private::EventBind.new( event_type, &block )
      connector = nil
      connector
    end

    def bind_once ( event_type, &block )
      return unless block
      connector = self.bind(event_type) { |event| block.call event; connector.disconnect }
      connector
    end

    def each_bind
      @_binds.each { |b| yield b }
      nil
    end
  end

  module Private
    class EventBind
      attr_accessor :event_type, :block

      def initialize( event_type, &block )
        raise "EventBind.new expected block" unless block
        event_type = EventType.new event_type unless event_type.is_a? EventType
        @event_type = event_type
        @block = block
      end
    end # EventBind
  end # Private
end
