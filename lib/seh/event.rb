require 'ostruct'

module Seh
  # @private
  module Private
    START = 0
    BEFORE = 100

    BEFORE_SUCCESS = 250
    BEFORE_FAILURE = 250

    SUCCESS = 500
    FAILURE = 500

    AFTER_SUCCESS = 750
    AFTER_FAILURE = 750

    AFTER = 900
    FINISH = 1000

    class EventData
      attr_accessor :types, :type_map, :target, :time, :staged_handlers, :success

      def initialize
        @types = []
        @type_map = {}
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
          apply_type_map data
        end

        def type_map( data, map = {} )
          map.each_pair do |type, implied_types|
            data.type_map[type] ||= []
            data.type_map[type].concat implied_types
            data.type_map[type].uniq!
          end
          apply_type_map data
        end

        private
        def apply_type_map( data )
          while true
            original_size = data.types.size
            data.type_map.each_pair { |type, implied_types| data.types.concat implied_types if data.types.include? type }
            data.types.uniq!
            break if original_size = data.types.size
          end
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

    def fail
      @data.success = false
    end

    def success?
      @data.success
    end

    def dispatch
      raise "Event#dispatch may only be called once" unless @state == Private::EventStateReady
      @state = Private::EventStateInflight
      collect_targets.each { |t| t.each_bind { |bind| bind.block.call self if bind.event_type.match @data.types } }
      @data.staged_handlers.each_key.sort.each { |stage| @data.staged_handlers[stage].each { |block| block.call self } }
      @state = Private::EventStateDone
    end

    def target
      @data.target
    end

    def type( event_type )
      @state.type @data, event_type
      nil
    end

    def type_map( map )
      @state.type_map @data, map
      nil
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

    def before_success(&block)
      staged_handler Private::BEFORE_SUCCESS, ->e{ block.call e if e.success? } if block_given?
    end

    def before_failure(&block)
      staged_handler Private::BEFORE_FAILURE, ->e{ block.call e unless e.success? } if block_given?
    end

    def success(&block)
      staged_handler Private::SUCCESS, ->e{ block.call e if e.success? } if block_given?
    end

    def failure(&block)
      staged_handler Private::FAILURE, ->e{ block.call e unless e.success? } if block_given?
    end

    def after_success(&block)
      staged_handler Private::AFTER_SUCCESS, ->e{ block.call e if e.success? } if block_given?
    end

    def after_failure(&block)
      staged_handler Private::AFTER_FAILURE, ->e{ block.call e unless e.success? } if block_given?
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

    def collect_targets
      targets_working = [@data.target]
      targets_final = []
      while t = targets_working.shift do
        targets_final << t
        targets_working.concat t.parents if t.respond_to? :parents
      end
      targets_final.uniq
    end
  end
end
