require "rails_helper"

RSpec.describe Entitlement, type: :model do
  let(:event) { create(:event) }
  let(:manager) { Entitlement::PositionManager }
  let(:entitlement) { create(:entitlement, :with_access, event: event) }

  describe ".infinite?" do
    it "false for 'counter'" do
      allow(entitlement).to receive(:mode).and_return("counter")
      expect(entitlement.infinite?).to eq(false)
    end

    it "true for 'permanent'" do
      allow(entitlement).to receive(:mode).and_return("permanent")
      expect(entitlement.infinite?).to eq(true)
    end

    it "true for 'permanent_strict'" do
      allow(entitlement).to receive(:mode).and_return("permanent_strict")
      expect(entitlement.infinite?).to eq(true)
    end
  end

  context "before validations" do
    describe ".position " do
      it "calls position manager with action 'save'" do
        manager_instance = manager.new(entitlement)

        allow(manager).to receive(:new).twice.with(entitlement).and_return(manager_instance)
        allow(manager_instance).to receive(:start).with(action: :validate)

        expect(manager_instance).to receive(:start).with(action: :save)

        entitlement.valid?
      end

      it "adds the next memory_position to the new entitlement" do
        create(:access, entitlement: build(:entitlement, event: event))
        expect(entitlement.memory_position).to be(2)
      end
    end
  end
end
