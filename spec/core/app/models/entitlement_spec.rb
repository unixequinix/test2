require "rails_helper"

RSpec.describe Entitlement, type: :model do
  let(:event) { create(:event) }
  let(:entitlement) { create(:entitlement, :with_access, event: event) }

  it "checks if it is infinite" do
    allow(entitlement).to receive(:mode).and_return("counter")
    expect(entitlement.infinite?).to eq(false)

    allow(entitlement).to receive(:mode).and_return("permanent")
    expect(entitlement.infinite?).to eq(true)

    allow(entitlement).to receive(:mode).and_return("permanent_strict")
    expect(entitlement.infinite?).to eq(true)
  end

  context "before validations" do
    describe ".set_memory_position " do
      it "adds the first memory position to the first entitlement" do
        expect(entitlement.memory_position).to be(1)
      end

      it "adds the first memory position to the first entitlement" do
        create(:entitlement, :with_access, event: event)
        expect(entitlement.memory_position).to be(1)
      end
    end
  end
end
