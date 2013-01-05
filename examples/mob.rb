require 'seh'

class Mob
  include Seh::EventTarget
  attr_accessor :hp, :observers
  def initialize
    @hp = 100
    @observers = []
  end
end
