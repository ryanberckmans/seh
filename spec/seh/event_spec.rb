require 'spec_helper'

require 'seh/event'
require 'seh/event_target'

module Seh
  class ObservableEventTarget
    include EventTarget
    def initialize
      @observers = []
    end
    attr_accessor :observers
  end

  describe Event do
    it "adds a few targets" do
      target1 = EventTarget::Default.new
      target2 = EventTarget::Default.new
      expect { subject.target target1, target2 }.to change{ subject.send :collect_targets }.from(Set.new).to(Set.new << target1 << target2)
    end

    it "dispatch runs target and then stage callbacks" do
      subject.should_receive(:run_target_callbacks).once.ordered
      subject.should_receive(:run_stage_callbacks).once.ordered
      subject.dispatch
    end

    it "dispatch may not be run twice" do
      subject.dispatch
      expect { subject.dispatch }.to raise_error
    end

    context "testing callbacks" do
      before :each do
        @counter = 0
        @callback = ->event{
          @counter += 1
        }
      end

      context "testing stage callbacks" do
        it "runs a start callback" do
          expect { subject.start &@callback}.to change{ subject.send :run_stage_callbacks; @counter }.from(0).to(1)
        end
        it "runs a finish callback" do
          expect { subject.finish &@callback}.to change{ subject.send :run_stage_callbacks; @counter }.from(0).to(1)
        end
        it "runs a stage callback" do
          stage = :foo
          subject.add_stage stage
          expect { subject.bind stage, &@callback}.to change{ subject.send :run_stage_callbacks; @counter }.from(0).to(1)
        end
        it "runs start before a stage" do
          result = []
          subject.add_stage :stage2
          subject.bind :stage2 do result << :second end
          subject.start { result << :first }
          subject.send :run_stage_callbacks
          result.should eq([:first,:second])
        end
        it "runs finish after a stage" do
          result = []
          subject.add_stage :stage2
          subject.bind :stage2 do result << :first end
          subject.finish { result << :second }
          subject.send :run_stage_callbacks
          result.should eq([:first,:second])
        end
        it "runs stages the order they were added" do
          result = []
          subject.add_stage :stage2
          subject.add_stage :stage3
          subject.add_stage :stage4
          subject.bind :stage4 do result << :third end
          subject.bind :stage3 do result << :second end
          subject.bind :stage2 do result << :first end
          subject.send :run_stage_callbacks
          result.should eq([:first,:second,:third])
        end
      end

      context "testing invoking of target callbacks" do
        before :each do
          @target = EventTarget::Default.new
          @type = :some_type
          subject.target @target
          subject.type @type
        end
        
        it "calls a target callback" do
          expect { @target.bind @type, &@callback }.to change{ subject.send :run_target_callbacks; @counter}.from(0).to(1)
        end

        it "passes self to a target callback" do
          @result = nil
          @target.bind @type do |event| @result = event end
          subject.send:run_target_callbacks
          @result.should eq(subject)
        end
      end
    end # testing callbacks
    

    context "with a target containing a DAG of observers" do
      before :each do
        @target1 = ObservableEventTarget.new
        @observer1 = EventTarget::Default.new
        @observer2 = EventTarget::Default.new
        @observer3 = ObservableEventTarget.new
        @observer4 = ObservableEventTarget.new
        @observer5 = EventTarget::Default.new
        
        @observer3.observers << @observer2
        @observer3.observers << @observer4
        @observer4.observers << @observer5 << @observer1

        @target2 = ObservableEventTarget.new
        @observer6 = EventTarget::Default.new

        @target2.observers << @observer6
        
        @target1.observers << @observer1 << @observer2 << @observer3
      end

      it "collects_targets in a Set which traverses the observer graph" do
        expect { subject.target @target1, @observer5, @target2 }.to change { subject.send :collect_targets}.from(Set.new).to(Set.new << @target1 << @target2 << @observer1 << @observer2 << @observer3 << @observer4 << @observer5 << @observer6 )
      end
    end
  end
end
