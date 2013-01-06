module Event
  class << self
    def hostile_template event_template
      event_template.types << :hostile
    end
    
    def hostile event, aggressor, aggressee
      event.target aggressor, aggressee
      event.type :hostile
      event.aggressor = aggressor
      event.aggressee = aggressee
      nil
    end
  end
  HOSTILE_TEMPLATE = hostile_template Seh::EventTemplate.new
end
