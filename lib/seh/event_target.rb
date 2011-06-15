module Seh
  module EventTarget
    def bind( event_type, &block )
      raise "EventTarget::bind expects a block" unless block
      @_binds ||= []
      bind = Private::EventBind.new( event_type, &block )
      @_binds << bind
      ->{ @_binds.delete bind }
    end

    def bind_once( event_type, &block )
      return unless block
      disconnect = self.bind(event_type) { |event| disconnect.call; block.call event }
      disconnect
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
        event_type = EventType.new event_type unless event_type.is_a? EventType
        @event_type = event_type
        @block = block
      end
    end # EventBind
  end # Private
end
