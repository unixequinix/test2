require "rails_helper"

RSpec.describe Entitlement::PositionUpdater, type: :domain_logic do
  let(:position_updater) do
    Entitlement::PositionUpdater.new(create(:entitlement, :with_access))
  end
  let(:event) { position_updater.entitlement.event }
  let(:entitlement) { position_updater.entitlement }

  describe ".change_memory_position" do
    it "changes the memory position of the items with a higher id than self" do
      entitlement2 = create(:entitlement, :with_access, event: event)
      value = rand(5)
      expect do
        position_updater.change_memory_position(value)
      end.to change { entitlement2.reload.memory_position } .by(value)
    end
  end

  describe ".calculate_memory_position_after_destroy" do
    it "decrements the memory position of the items with a higher id than self" do
      entitlement2 = create(:entitlement, :with_access, event: event)
      expect do
        position_updater.calculate_memory_position_after_destroy
      end.to change { entitlement2.reload.memory_position } .by(-entitlement.memory_length)
    end
  end

  describe ".calculate_memory_position_after_update" do
    context "enough space in gtag" do
      it "increments the memory position of the items with a higher id than self" do
        entitlement2 = create(:entitlement, :with_access, event: event)
        allow_any_instance_of(Entitlement::PositionUpdater).to receive(:step).and_return(1)
        expect do
          position_updater.calculate_memory_position_after_update
        end.to change { entitlement2.reload.memory_position } .by(1)
      end
    end
    context "not enough space in gtag" do
      it "increments the memory position of the items with a higher id than self" do
        allow_any_instance_of(Entitlement::PositionUpdater).to receive(:step).and_return(1)
        allow_any_instance_of(Entitlement::PositionUpdater).to receive(:limit).and_return(1)

        position_updater.calculate_memory_position_after_update
        expect(entitlement.errors.count).to eq(1)
      end
    end
  end
end
