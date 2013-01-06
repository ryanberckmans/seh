require 'set'
require 'ostruct'

module Seh
  class Event < OpenStruct
    def initialize
      super
      @state = :ready
      @types = Set.new
      @targets = Set.new
      @start_callbacks = []
      @finish_callbacks = []
      @stage_callbacks = {}
      @stage_decision_blocks = {}
      @stages = Set.new
      @abort = false
      yield self if block_given?
    end

    # Dispatch this event, notifying all targets of the event and executing any callbacks.
    # #dispatch may only be called once
    # Dispatch algorithm:
    #  1. determine the full set of targets affected by this event
    #  2. run target callbacks which match this event's types
    #  3. run stage callbacks contained in this event; typically targets will append stage callbacks to this event using Event#bind, #start, #finish
    #     Callback execution order:
    #       start callbacks
    #       stage callabcks - in the order stages were added
    #       finish callbacks
    #     Callbacks in the same stage have arbitrary execution order
    # @return nil
    def dispatch
      raise "Event#dispatch may only be called once" unless @state == :ready
      @state = :inflight
      return if @abort
      run_target_callbacks
      run_stage_callbacks
      @state = :done
      nil
    end

    # Abort this Event. After #abort is called, some in-progress work may still be completed.
    # Abort semantics:
    #   - if #abort is called before #dispatch, #dispatch return immediately, no target will know the event occurred, and no callbacks will be executed
    #   - if #abort is called by a target while visiting the set of targets, each target will still receive the event but no stage callbacks will be exewcuted
    #   - if #abort is called during start callbacks, start will complete and no stage or finish callbacks will be run
    #   - if #abort is called during a stage callback, the current stage will complete and no other stage or finish callbacks will be run
    #   - if #abort is called during a finish callback, finish will complete, i.e. calling #abort during a finish callbacks is fairly pointless
    # @return nil
    def abort
      @abort = true
      nil
    end

    # Add targets to this event. May not be called after or during #dispatch
    # @param targets - zero or more EventTarget objects to add to this event
    # @return nil
    def target *targets
      raise "Event#target is disallowed after Event#dispatch is called" unless @state == :ready
      targets.each { |target| @targets << target }
      nil
    end

    # Add event types to this event. May not be called after or during #dispatch
    # @param types - zero or more types to add to this Event. The Event is simultaneously all of these types
    # @return nil
    def type *event_types
      raise "Event#type is disallowed after Event#dispatch is called" unless @state == :ready
      event_types.each { |type| @types << type }
      nil
    end

    # Add the passed new stage to this event
    # @param new_stage - a stage to add to this event
    # @block - a block with a single parameter |event|; during #dispatch, this block will be called with self immediately prior to executing new_stage's callbacks. new_stage and its callbacks will be skipped (not executed) if this block returns falsy.
    # @return nil
    def add_stage new_stage, &stage_decision_block
      raise "Event#add_stage is disallowed after Event#dispatch is called" unless @state == :ready
      @stages << new_stage
      @stage_callbacks[new_stage] ||= []
      @stage_decision_blocks[new_stage] = stage_decision_block if block_given?
      nil
    end

    # Return true if this event's types match the passed EventType
    # @param event_type - an EventType to match against this event's types
    # @return true or false - result of passed EventType#match on this event's types
    def match_type? event_type
      event_type = EventType.new event_type unless event_type.is_a? EventType
      event_type.match @types
    end

    # Bind the passed block as a callback for the passed stage
    # @param stage - a stage which has been added using #add_stage
    # @block - a callback receiving a single parameter, |event|, which will be added to stage's callbacks
    # @return nil
    def bind stage, &block
      @stage_callbacks[stage] << block if block_given?
      nil
    end

    # Bind the passed block as a start callback
    # @block - a callback receiving a single parameter, |event|, which will be added to the start callbacks
    # @return nil
    def start &block
      @start_callbacks << block if block_given?
      nil
    end

    # Bind the passed block as a finish callback
    # @block - a callback receiving a single parameter, |event|, which will be added to the finish callbacks
    # @return nil
    def finish &block
      @finish_callbacks << block if block_given?
      nil
    end

    private
    # Used in #dispatch, run callbacks that match our types on each target in the target closure
    def run_target_callbacks
      collect_targets.each do |target|
        target.each_matching_callback(@types) { |callback| callback.call self }
      end
    end

    # Used in #dispatch, run the stage callbacks on this event; to be run after each target had a chance to append callbacks
    # Callback execution order:
    #  start callbacks
    #  stage callabcks - in the order stages were added
    #  finish callbacks
    # Callbacks in the same stage have arbitrary execution order
    def run_stage_callbacks
      return if @abort
      @start_callbacks.each { |block| block.call self }
      @stages.each do |stage|
        return if @abort
        @stage_callbacks[stage].each { |block| block.call self }
      end
      return if @abort
      @finish_callbacks.each { |block| block.call self }
    end

    # Compute the target closure, equal to the set of targets on this event and their observers (and recursive observers)
    def collect_targets
      all_targets = @targets.dup # @targets must remain the original set of targets on this event, and all_targets will be mutated.  NOTE: @targets isn't actually used after collect_targets() is called, so we might remove the .dup()
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
