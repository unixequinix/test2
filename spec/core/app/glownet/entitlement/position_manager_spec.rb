require "rails_helper"

RSpec.describe Entitlement::PositionManager, type: :domain_logic do
  let(:position_manager) do
    Entitlement::PositionManager.new(create(:entitlement, :with_access))
  end

  describe ".start" do
    it "calls the right memory_position method depending on the action (save) " do
      expect(position_manager).to receive(:save_memory_position)
      params = { action: :save }
      position_manager.start(params)
    end
    it "calls the right memory_position method depending on the action (validate) " do
      expect(position_manager).to receive(:validate_memory_position)
      params = { action: :validate }
      position_manager.start(params)
    end
    it "calls the right memory_position method depending on the action (destroy) " do
      expect(position_manager).to receive(:destroy_memory_position)
      params = { action: :destroy }
      position_manager.start(params)
    end
  end

  describe ".save_memory_position" do
    context "with a new entitlement" do
      it "calls the method to retrieve the right memory position" do
        position_manager_a = Entitlement::PositionManager.new(build(:entitlement, :with_access))
        allow_any_instance_of(Entitlement::PositionManager).to receive(:step).and_return(1)
      end
    end
  end
end
