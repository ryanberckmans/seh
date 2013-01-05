require 'spec_helper'
require 'seh/event_bind_disconnector'

module Seh
  describe EventBindDisconnector do
    before :each do @proc = ->{ "nice!" } end
    subject { EventBindDisconnector.new @proc }

    it "calls proc on disconnect" do
      @proc.should_receive(:call).once
      subject.disconnect
    end

    its(:disconnect) { should be_nil }

    it "sets the proc reference to nil on disconnect, so the proc is only ever called once" do
      @proc.should_receive(:call).once
      subject.disconnect
      subject.disconnect
      subject.disconnect
    end
  end
end
