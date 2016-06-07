require "rails_helper"

RSpec.describe Entitlement::PositionCreator, type: :domain_logic do
  let(:position_creator) do
    Entitlement::PositionCreator.new(create(:entitlement, :with_access))
  end
  describe ".create_new_position" do
    context "last position is nil" do
      it "should return 1 (as a first position)" do
        allow(position_creator).to receive(:last_element).and_return(nil)
        expect(position_creator.create_new_position).to be(1)
      end
    end
    context "last position is nil" do
      it "should return 1 (as a first position)" do
        allow(position_creator).to receive(:last_element).and_return( { memory_position: 1, memory_length: 2 } )
        expect(position_creator.create_new_position).to be(1)
      end
    end
  end
end
