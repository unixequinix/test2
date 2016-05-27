require "rails_helper"

RSpec.describe Entitlement, type: :model do
  let(:entitlement) {
    ci = create(:catalog_item, :with_access)
    ci.catalogable.entitlement
  }

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
      it "adds the right position to a new entitlement" do
        binding.pry
        create(:catalog_item, :with_access)
        expec(Entitlement.new.set_memory_position).to be()
      end
    end
  end
end
