module Event
  class << self
    def hostile event, aggressor, aggressee
      event.target aggressor, aggressee
      event.type :hostile
      event.aggressor = aggressor
      event.aggressee = aggressee
      nil
    end
  end
end
