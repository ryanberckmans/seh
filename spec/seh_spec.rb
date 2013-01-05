require 'spec_helper'
require 'seh'

describe Seh do
  context "with data to test EventType aliases" do
    before :each do
      @x = :one
      @y = :two
      @z = :three
      @result = double Seh::EventType
    end
    it "delegates Seh::and to EventType" do
      Seh::EventType::And.should_receive(:new).with(@x,@y,@z).once.and_return @result
      Seh::and(@x,@y,@z).should eq(@result)
    end
    it "delegates Seh::or to EventType" do
      Seh::EventType::Or.should_receive(:new).with(@x,@y,@z).once.and_return @result
      Seh::or(@x,@y,@z).should eq(@result)
    end
    it "delegates Seh::not to EventType" do
      Seh::EventType::Not.should_receive(:new).with(@x).once.and_return @result
      Seh::not(@x).should eq(@result)
    end
  end
end
