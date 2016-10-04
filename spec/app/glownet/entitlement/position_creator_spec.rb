require "rails_helper"

RSpec.describe Entitlement::PositionCreator, type: :domain_logic do
  let(:position_creator) do
    Entitlement::PositionCreator.new(create(:entitlement, :with_access))
  end

  describe ".create_new_position" do
    it "when last position is nil returns 1 (as a first position)" do
      allow(position_creator).to receive(:last_element).and_return(nil)
      expect(position_creator.create_new_position).to be(1)
    end

    it "last position not nil returns the sum of position and length" do
      obj = instance_double("Entitlement", memory_position: 11, memory_length: 5)
      allow(position_creator).to receive(:last_element).and_return(obj)
      expect(position_creator.create_new_position).to be(16)
    end
  end
end
