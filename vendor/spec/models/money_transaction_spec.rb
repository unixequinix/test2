require "rails_helper"

RSpec.describe MoneyTransaction, type: :model do
  subject { create(:money_transaction, event: build(:event), action: "something") }

  describe ".description" do
    it "formats the price correctly in .description" do
      allow(subject).to receive(:price).and_return(2)
      expect(subject.description.split(" ")[0]).to include("Something")
      expect(subject.description.split(" ")[1]).to eq("2.00")
      expect(subject.description.split(" ")[2]).to eq(subject.event.currency_symbol)
    end
  end

  describe ".mandatory_fields" do
    %w[items_amount price payment_method].each do |field|
      it "includes the mandatory field '#{field}'" do
        expect(MoneyTransaction.mandatory_fields).to include(field)
      end
    end
  end
end
