require 'spec_helper'
require 'seh/event_bind'
require 'seh/event_type'

module Seh
  describe EventBind do
    before :each do
      @event_type = EventType.new :some_type
      @block = ->{ callback! }
    end
    subject { EventBind.new @event_type, &@block  }
    its(:block) { should eq(@block) }
    its(:event_type) { should eq(@event_type) }

    it "wraps a non-EventType in an EventType" do
      type = :not_an_EventType
      puts EventType.should_receive(:new).with(type).once.and_call_original
      bind = EventBind.new type, &@block
      bind.event_type.should be_a(EventType)
    end
  end
end
