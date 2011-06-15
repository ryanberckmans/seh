module Seh
  module Private
    class EventData
      attr_accessor :types, :target, :time

      def initialize
        @types = []
        @target = nil
        @time = Time.now
      end
    end

    class EventStateReady
      class << self
        def type( data, t )
          data.types << t
        end
      end
    end

    class EventStateInflight
    end

    class EventStateDone
    end
  end

  class Event
    def initialize(target, &block)
      raise "Event expects a target" unless target
      raise "Event expects the target to include EventTarget" unless target.class.include? EventTarget
      @state = Private::EventStateReady
      @data = Private::EventData.new
      @data.target = target
      instance_eval(&block) if block
    end

    def dispatch
      raise "Event may only be dispatched once" unless @state == Private::EventStateReady
      @state = Private::EventStateInflight
      @data.target.each_bind { |bind| bind.block.call self if bind.event_type.match @data.types }
      @state = Private::EventStateDone
    end

    def target
      @data.target
    end

    def type( event_type )
      @state.type @data, event_type
    end

    def match_type( event_type )
      event_type.match @data.types
    end

    def time
      @data.time.dup
    end
  end
end
