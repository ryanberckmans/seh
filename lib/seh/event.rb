require 'set'
require 'ostruct'

module Seh
  # @private
  module Private
    class EventData
      attr_accessor :types, :targets, :time, :priority_handlers, :start_handlers, :finish_handlers, :success

      def initialize
        @types = []
        @targets = Set.new
        @time = Time.now
        @success = true

        @start_handlers = []
        @finish_handlers = []
        @priority_handlers = {}
      end
    end

    class EventStateReady
      class << self
        def type( data, t )
          data.types << t
        end

        def target( data, target )
          raise "Seh::Event expects a non-nil target to include EventTarget" unless target and target.class.include? EventTarget
          data.targets << target
        end
      end
    end

    class EventStateInflight
    end

    class EventStateDone
    end
  end

  class Event < OpenStruct
    def initialize(opts={}, &block)
      super
      opts[:dispatch] ||= true
      @state = Private::EventStateReady
      @data = Private::EventData.new
      instance_eval(&block) if block
      dispatch if @state == Private::EventStateReady and opts[:dispatch]
    end

    def fail
      @data.success = false
    end

    def success?
      @data.success
    end

    def dispatch
      raise "Event#dispatch may only be called once" unless @state == Private::EventStateReady
      @state = Private::EventStateInflight
      collect_targets.each do |target|
        target.each_matching_callback(@data.types) { |callback| callback.call self }
      end
      @data.start_handlers.each { |block| block.call self }
      @data.priority_handlers.each_key.sort.each { |stage| @data.priority_handlers[stage].each { |block| block.call self } }
      @data.finish_handlers.each { |block| block.call self }
      @state = Private::EventStateDone
    end

    def target( *targets )
      targets.each { |t| @state.target @data, t }
      nil
    end

    def type( *event_types )
      event_types.each { |t| @state.type @data, t }
      nil
    end

    def match_type( event_type )
      event_type = EventType.new event_type unless event_type.is_a? EventType
      event_type.match @data.types
    end

    def time
      @data.time.dup
    end

    def bind( priority, &block )
      priority_handler priority, block if block_given?
    end

    def bind_success( priority, &block )
      priority_handler priority, ->e{ block.call e if e.success? } if block_given?
    end

    def bind_failure( priority, &block )
      priority_handler priority, ->e{ block.call e unless e.success? } if block_given?
    end

    def start( &block )
      @data.start_handlers << block if block_given?
    end

    def finish( &block )
      @data.finish_handlers << block if block_given?
    end

    def finish_success( &block )
      @data.finish_handlers << ->e{ block.call e if e.success? } if block_given?
    end

    def finish_failure( &block )
      @data.finish_handlers << ->e{ block.call e unless e.success? } if block_given?
    end

    private
    def priority_handler( stage, block )
      @data.priority_handlers[stage] ||= []
      @data.priority_handlers[stage] << block
      nil
    end

    def collect_targets
      all_targets = @data.targets.dup
      observers = Set.new
      begin
        original_size = all_targets.size
        all_targets.each { |target| observers.merge target.observers }
        all_targets.merge observers
      end while all_targets.size != original_size
      all_targets
    end
  end
end
