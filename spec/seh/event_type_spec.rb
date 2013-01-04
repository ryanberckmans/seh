require 'spec_helper'
require 'seh/event_type'

module Seh
  describe EventType do
    before :each do
      @type = :some_type
      @type1 = :type1
      @type2 = :type2
      @type3 = :type3
      @type4 = :type4
    end

    context "with a single basic type" do
      subject { EventType.new :some_type }

      it { subject.match([@type]).should be_true }
      it { subject.match([@type, :another, :bar]).should be_true }
      it { subject.match([:foo, :bar, @type]).should be_true }

      it { subject.match([nil]).should be_false }
      it { subject.match([:wrong_type]).should be_false }
      it { subject.match([:wrong_type, :bar, :bazz]).should be_false }
      it { subject.match([]).should be_false }
    end

    context "And with only basic types nested" do
      subject { EventType::And.new @type1, @type2, @type3 }

      it { subject.match([@type1,@type3,@type2]).should be_true }
      it { subject.match([@type1,@type3,@type2,:another_type]).should be_true }
      
      it { subject.match([@type1]).should be_false }
      it { subject.match([@type2]).should be_false }
      it { subject.match([@type3]).should be_false }
      it { subject.match([@type1,@type2]).should be_false }
      it { subject.match([@type3,@type2]).should be_false }
      
      it { subject.match([nil]).should be_false }
      it { subject.match([]).should be_false }
    end

    context "Or with only basic types nested" do
      subject { EventType::Or.new @type1, @type2, @type3 }

      it { subject.match([@type1]).should be_true }
      it { subject.match([@type2]).should be_true }
      it { subject.match([@type3]).should be_true }
      it { subject.match([@type1,@type2,@type3]).should be_true }
      it { subject.match([@type1,:another_type]).should be_true }

      it { subject.match([:another_type, :another_again_type]).should be_false }
      it { subject.match([nil]).should be_false }
      it { subject.match([]).should be_false }
    end

    context "Not with only a basic type nested" do
      subject { EventType::Not.new @type1 }

      it { subject.match([nil]).should be_true }
      it { subject.match([]).should be_true }
      it { subject.match([@type2,@type3]).should be_true }

      it { subject.match([@type1]).should be_false }
      it { subject.match([@type1,:another_type]).should be_false }
    end

    context "And with two nested Nots" do
      subject { EventType::And.new @type2, EventType::Not.new(@type1), EventType::Not.new(@type3) }

      it { subject.match([@type2]).should be_true }
      it { subject.match([@type2,:bar]).should be_true }

      it { subject.match([@type1,@type2]).should be_false }
      it { subject.match([@type3,@type2]).should be_false }
      it { subject.match([@type3,@type1]).should be_false }
      it { subject.match([@type1]).should be_false }
      it { subject.match([:another_type]).should be_false }
      it { subject.match([nil]).should be_false }
      it { subject.match([]).should be_false }
    end

    context "Or with a nested And" do
      subject { EventType::Or.new @type2, EventType::And.new(@type1,@type3) }
      it { subject.match([@type2]).should be_true }
      it { subject.match([@type1,@type3]).should be_true }
      it { subject.match([@type1,@type3,@type2]).should be_true }
      
      it { subject.match([@type1]).should be_false }
      it { subject.match([@type3]).should be_false }
      it { subject.match([:another_type]).should be_false }
      it { subject.match([nil]).should be_false }
      it { subject.match([]).should be_false }
    end

    context "A more complicated nested example" do
      subject do
        EventType::Or.new(
                          @type,
                          EventType::And.new(@type1,@type2),
                          EventType::And.new(@type2,@type3),
                          EventType::And.new(@type4,EventType::Not.new(@type3)),
                          EventType::Or.new(:success)
                          )
      end

      it { subject.match([:success]).should be_true }
      it { subject.match([:success,@type3]).should be_true }
      it { subject.match([@type]).should be_true }
      it { subject.match([@type1,@type2]).should be_true }
      it { subject.match([@type2,@type3]).should be_true }
      it { subject.match([@type4]).should be_true }

      it { subject.match([@type1,@type3]).should be_false }
      it { subject.match([@type4,@type3]).should be_false }
      it { subject.match([@type1]).should be_false }
      it { subject.match([@type2]).should be_false }
      it { subject.match([@type3]).should be_false }
      it { subject.match([:another_type]).should be_false }
      it { subject.match([nil]).should be_false }
      it { subject.match([]).should be_false }
    end
  end
end
