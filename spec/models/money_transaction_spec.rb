require "spec_helper"

RSpec.describe MoneyTransaction, type: :model do
  subject { create(:money_transaction, event: build(:event)) }

  describe ".description" do
    it "formats the price correctly in .description" do
      allow(subject).to receive(:price).and_return(2)
      expect(subject.description.split(" ").last).to eq("2.00")
    end
  end

  describe ".mandatory_fields" do
    %w[catalog_item_id items_amount price payment_method].each do |field|
      it "includes the mandatory field '#{field}'" do
        expect(MoneyTransaction.mandatory_fields).to include(field)
      end
    end
  end
end
