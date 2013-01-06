
module Seh
  # EventTemplate contains the most frequently reused Event data, to prevent duplicate reconstruction across Events
  class EventTemplate
    attr_reader( :types, # Set of event type
                 :stages, # Set of stages
                 :stage_decision_blocks, # Hash of stage -> block ; stage should appear in :stages, block takes one parameter |event|, see Event#add_stage
                 :start_callbacks,
                 :finish_callbacks,
                 :stage_callbacks
                 )

    def initialize
      @types = Set.new
      @stage_decision_blocks = {}
      @stages = Set.new
      @start_callbacks = []
      @finish_callbacks = []
      @stage_callbacks = {}
    end

    # TODO - this is duplicate code with Event#add_stage
    # Add the passed new stage to this event
    # May not be used if this Event was constructed with an EventTemplate
    # @param new_stage - a stage to add to this event
    # @block - a block with a single parameter |event|; during #dispatch, this block will be called with self immediately prior to executing new_stage's callbacks. new_stage and its callbacks will be skipped (not executed) if this block returns falsy.
    # @return nil
    def add_stage new_stage, &stage_decision_block
      @stages << new_stage
      @stage_callbacks[new_stage] ||= []
      @stage_decision_blocks[new_stage] = stage_decision_block if block_given?
      nil
    end

    # TODO - this is duplicate code with Event#bind
    # Bind the passed block as a callback for the passed stage
    # @param stage - a stage which has been added using #add_stage
    # @block - a callback receiving a single parameter, |event|, which will be added to stage's callbacks
    # @return nil
    def bind stage, &block
      @stage_callbacks[stage] ||= []
      @stage_callbacks[stage] << block if block_given?
      nil
    end

    # TODO duplicate with Event#start
    # Bind the passed block as a start callback
    # @block - a callback receiving a single parameter, |event|, which will be added to the start callbacks
    # @return nil
    def start &block
      @start_callbacks << block if block_given?
      nil
    end

    # TODO duplicate with Event#finish
    # Bind the passed block as a finish callback
    # @block - a callback receiving a single parameter, |event|, which will be added to the finish callbacks
    # @return nil
    def finish &block
      @finish_callbacks << block if block_given?
      nil
    end
  end
end
