require "rails_helper"

RSpec.describe OrderTransaction, type: :model do
  subject { create(:order_transaction) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".mandatory_fields" do
    it "includes the correct fields" do
      expect(OrderTransaction.mandatory_fields).to include("catalog_item_id")
    end
  end
end
