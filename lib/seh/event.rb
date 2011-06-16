require 'ostruct'

module Seh
  module Private
    START = 0
    BEFORE = 100

    AFTER = 900
    FINISH = 1000

    class EventData
      attr_accessor :types, :target, :time, :staged_handlers
      attr_reader :success

      def initialize
        @types = []
        @target = nil
        @time = Time.now
        @success = true

        # staged handlers
        @staged_handlers = {}
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

  class Event < OpenStruct
    def initialize(target, &block)
      super()
      raise "Event expects a target" unless target
      raise "Event expects the target to include EventTarget" unless target.class.include? EventTarget
      @state = Private::EventStateReady
      @data = Private::EventData.new
      @data.target = target
      instance_eval(&block) if block
    end

    def success?
      @data.success
    end

    def dispatch
      raise "Event may only be dispatched once" unless @state == Private::EventStateReady
      @state = Private::EventStateInflight
      @data.target.each_bind { |bind| bind.block.call self if bind.event_type.match @data.types }
      @data.staged_handlers.each_key.sort.each { |stage| @data.staged_handlers[stage].each { |block| block.call self } }
      @state = Private::EventStateDone
    end

    def target
      @data.target
    end

    def type( event_type )
      @state.type @data, event_type
    end

    def match_type( event_type )
      event_type = EventType.new event_type unless event_type.is_a? EventType
      event_type.match @data.types
    end

    def time
      @data.time.dup
    end

    def start(&block)
      staged_handler Private::START, block if block_given?
    end

    def before(&block)
      staged_handler Private::BEFORE, block if block_given?
    end

    def after(&block)
      staged_handler Private::AFTER, block if block_given?
    end

    def finish(&block)
      staged_handler Private::FINISH, block if block_given?
    end

    private
    def staged_handler( stage, block )
      @data.staged_handlers[stage] ||= []
      @data.staged_handlers[stage] << block
      nil
    end
  end
end
