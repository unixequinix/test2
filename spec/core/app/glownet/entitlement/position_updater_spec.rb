require "rails_helper"

RSpec.describe Entitlement::PositionUpdater, type: :domain_logic do
  let(:event) { position_updater.entitlement.event }
  let(:position_updater) do
    Entitlement::PositionUpdater.new(create(:entitlement, :with_access))
  end

  describe ".change_memory_position" do
    it "should change the memory position of the items with an higher id than self" do
      entitlement2 = create(:entitlement, :with_access, event: event)
      value = rand(5)
      expect do
         position_updater.change_memory_position(value)
      end.to change { entitlement2.reload.memory_position } .by(value)
    end
  end
end
