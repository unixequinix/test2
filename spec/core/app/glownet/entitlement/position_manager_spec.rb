require "rails_helper"

RSpec.describe Entitlement::PositionManager, type: :domain_logic do
  let(:position_manager) do
    Entitlement::PositionUpdater.new(create(:entitlement, :with_access))
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

  describe ".gtag_type" do
    it "returns the gtag_type defined for the current event" do
      types = %(mifare_classic ultralight_ev1 ultralight_c)
      expect(types).to include(position_manager.gtag_type)
    end
  end
end
