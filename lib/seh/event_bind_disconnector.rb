module Seh
  # EventBindDisconnector should not be used directly. Event#bind and Event#bind_once return instances of EventBindDisconnector.
  class EventBindDisconnector
    def initialize disconnect_proc
      @disconnect_proc = disconnect_proc
    end

    # Disconnect this bind from its EventTarget
    def disconnect
      unless @disconnect_proc.nil?
        @disconnect_proc.call
        @disconnect_proc = nil
      end
      nil
    end
  end
end
