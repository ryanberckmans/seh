module Seh
  module EventTarget
    def bind( event_type=nil, &block )
      raise "EventTarget::bind expects a block" unless block_given?
      @_binds ||= []
      bind = Private::EventBind.new( event_type, &block )
      @_binds << bind
      BindDisconnector.new ->{ @_binds.delete bind; nil }
    end

    def bind_once( event_type=nil, &block )
      return unless block_given?
      disconnect = self.bind(event_type) { |event| disconnect.call; block.call event }
      disconnect
    end

    def each_bind
      @_binds ||= []
      @_binds.dup.each { |b| yield b }
      nil
    end

    class BindDisconnector
      def initialize( disconnect_proc )
        @disconnect_proc = disconnect_proc
      end

      def disconnect
        @disconnect_proc.call
      end
    end
  end

  # @private
  module Private
    class EventBind
      attr_reader :event_type, :block

      def initialize( event_type, &block )
        event_type = EventType.new event_type unless event_type.is_a? EventType
        @event_type = event_type
        @block = block
      end
    end # EventBind
  end # Private
end
