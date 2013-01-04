require 'set'
require 'ostruct'

module Seh
  # @private
  module Private
    class EventData
      attr_accessor :types, :targets, :stage_callbacks, :start_callbacks, :finish_callbacks

      def initialize
        @types = []
        @targets = Set.new

        @start_callbacks = []
        @finish_callbacks = []
        @stage_callbacks = {}
      end
    end

    class EventStateReady
      class << self
        def type data, t
          data.types << t
        end

        def target data, target
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
    def initialize opts={}, &block
      super
      opts[:dispatch] ||= true
      @state = Private::EventStateReady
      @data = Private::EventData.new
      instance_eval(&block) if block
      dispatch if @state == Private::EventStateReady and opts[:dispatch]
    end

    def dispatch
      raise "Event#dispatch may only be called once" unless @state == Private::EventStateReady
      @state = Private::EventStateInflight
      collect_targets.each do |target|
        target.each_matching_callback(@data.types) { |callback| callback.call self }
      end
      @data.start_callbacks.each { |block| block.call self }
      each_stage do |stage|
        @data.stage_callbacks[stage].each { |block| block.call self }
      end
      @data.finish_callbacks.each { |block| block.call self }
      @state = Private::EventStateDone
    end

    def target *targets
      targets.each { |t| @state.target @data, t }
      nil
    end

    def type *event_types
      event_types.each { |t| @state.type @data, t }
      nil
    end

    def match_type event_type
      event_type = EventType.new event_type unless event_type.is_a? EventType
      event_type.match @data.types
    end

    def bind stage, &block
      @data.stage_callbacks[stage] = block if block_given?
      nil
    end

    def start &block
      @data.start_callbacks << block if block_given?
      nil
    end

    def finish &block
      @data.finish_callbacks << block if block_given?
      nil
    end

    def add_stage new_stage, *new_stage_dependencies, &stage_test_block
      @stages ||= []
      @stages << new_stage
      @stage_blocks ||= {}
      @stage_blocks[new_stage] = stage_test_block if block_given?
      nil
    end

    private
    def collect_targets
      all_targets = @data.targets.dup # @data.targets must remain the original set of targets on this event, and all_targets will be mutated
      observers = Set.new
      begin
        original_size = all_targets.size
        all_targets.each { |target| observers.merge target.observers }
        all_targets.merge observers
      end while all_targets.size != original_size
      all_targets
    end

    def each_stage
      @stages ||= []
      @stages.each { |stage| yield stage }
      nil
    end
  end
end
