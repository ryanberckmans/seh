module Event
  class << self
    def hostile_template event_template
      event_template.types << :hostile
    end
    
    def hostile_with_template event, aggressor, aggressee
      # event is expected to be initialized with hostile_template
      event.target aggressor, aggressee
      event.aggressor = aggressor
      event.aggressee = aggressee
      event
    end

    def hostile event, aggressor, aggressee
      event.type :hostile
      event.target aggressor, aggressee
      event.aggressor = aggressor
      event.aggressee = aggressee
      event
    end
  end
  HOSTILE_TEMPLATE = hostile_template Seh::EventTemplate.new
end
