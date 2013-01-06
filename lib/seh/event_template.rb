
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
  end
end
