require 'spec_helper'

require 'seh/event'

module Seh
  describe Event do
    context "new stage system example" do
      before :each do
        subject.add_stage :melee_attempt
        subject.add_stage(:melee_hit, :melee_attempt) { |event| event.attack_hit? }
        subject.add_stage(:melee_miss, :melee_attempt) { |event| !event.attack_hit? }
        subject.add_stage :melee_something_else
        subject.add_stage :melee_shared, :melee_hit, :melee_something_else
        subject.add_stage :melee_next, :melee_shared
        subject.add_stage :melee_fred
      end

      it "puts each_stage" do
        subject.each_stage do |stage| puts stage end
        puts "NEXT"
        subject.each_stage do |stage| puts stage end
      end
    end
  end
end
