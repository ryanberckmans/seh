require 'spec_helper'
require 'seh/event_target'
require 'seh/event_bind_disconnector'

module Seh
  module EventTarget
    describe Default do
      it { subject.should be_a(EventTarget) }

      its(:observers) { should eq([]) }

      it { subject.each_matching_callback([]).should be_nil }

      it "adds a bind" do
        event_type = :some_type
        block = -> { callback! }
        EventBind.should_receive(:new).with(event_type,&block).once.and_call_original
        bind_disconnector = subject.bind event_type, &block
        bind_disconnector.should be_a(EventBindDisconnector)
      end

      context "with added binds" do
        before :each do
          @event_type1 = :another_type
          @block1 = -> { callback! }
          @bind_disconnector1 = subject.bind @event_type1, &@block1

          @event_type2 = :second_type
          @block2 = -> { twocallback! }
          @bind_disconnector2 = subject.bind @event_type2, &@block2

          @event_type3 = :third_type
          @block3 = ->event{ "do nothing" }
          @bind_disconnector3 = subject.bind_once @event_type3, &@block3
        end

        it "yields the block for a matching bind in each_matching_callback" do
          expected_blocks = []
          subject.each_matching_callback([@event_type1]) { |block| expected_blocks << block }
          expected_blocks.should include(@block1)
          expected_blocks.size.should eq(1)
        end

        it "yields both blocks for the matching binds in each_matching_callback" do
          expected_blocks = []
          subject.each_matching_callback([@event_type1,@event_type2]) { |block| expected_blocks << block }
          expected_blocks.should include(@block1)
          expected_blocks.should include(@block2)
          expected_blocks.size.should eq(2)
        end

        it "yields nothing when no binds match the event_types in each_matching_callback" do
          expected_blocks = []
          subject.each_matching_callback([:unknown_type]) { |block| expected_blocks << block }
          expected_blocks.size.should eq(0)
        end

        it "disconnects bind3 after a single block invocation, since bind3 was connected using bind_once" do
          expected_blocks = []
          subject.each_matching_callback([@event_type3]) { |block| expected_blocks << block }
          expected_blocks.should_not include(@block3) # @block3 would have been wrapped in another block during bind_once, so we don't expect to find it
          expected_blocks.size.should eq(1) # the single block in the array is the new block wrapping @block3
          expected_blocks[0].call

          # After @block3 was called, we shouldn't expect to find it anymore
          expected_blocks.clear
          expected_blocks.size.should eq(0) # verify clear
          subject.each_matching_callback([@event_type3]) { |block| expected_blocks << block }
          expected_blocks.size.should eq(0)
        end

        context "with bind1 disconnected" do
          before :each do
            @bind_disconnector1.disconnect
          end

          it "yields only the second block in each_matching_callback, since the first was disconnected" do
            expected_blocks = []
            subject.each_matching_callback([@event_type1,@event_type2]) { |block| expected_blocks << block }
            expected_blocks.should include(@block2)
            expected_blocks.size.should eq(1)
          end
        end
      end
    end
  end
end
