require "rails_helper"

RSpec.describe Stats::Sale, type: :job do
  let(:worker) { Stats::Sale }
  let(:event) { create(:event) }
  let(:product) { create(:product) }
  let(:transaction) { create(:credit_transaction, action: "sale", event: event) }

  before { 3.times { |_i| transaction.sale_items.create! product_id: product.id, unit_price: 2, quantity: 3 } }

  it "creates one Stat per sale item" do
    expect { worker.perform_now(transaction.id) }.to change(Stat, :count).by(transaction.sale_items.size)
  end

  describe "Other amounts" do
    before { transaction.update other_amount_credits: 10 }

    it "creates one Stat for other amount if present" do
      expect { worker.perform_now(transaction.id) }.to change(Stat, :count).by(transaction.sale_items.size + 1)
    end

    it "with positive quantity if action is sale" do
      stat = worker.perform_now(transaction.id)
      expect(stat.sale_item_quantity).to be(1)
    end

    it "with negative quantity if action is anything else" do
      transaction.update action: "anything_else"
      stat = worker.perform_now(transaction.id)
      expect(stat.sale_item_quantity).to be(-1)
    end

    it "with name 'Other Product'" do
      stat = worker.perform_now(transaction.id)
      expect(stat.product_name).to eq("Other Product")
    end

    it "with correct total" do
      stat = worker.perform_now(transaction.id)
      expect(stat.sale_item_total_price).to eq(transaction.other_amount_credits)
    end

    it "with correct unit_price" do
      stat = worker.perform_now(transaction.id)
      expect(stat.sale_item_unit_price).to eq(transaction.other_amount_credits)
    end
  end
end
