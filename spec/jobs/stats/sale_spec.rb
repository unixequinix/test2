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
    before { transaction.sale_items.create! quantity: 1, unit_price: 15 }

    it "with positive quantity if action is sale" do
      stat = worker.perform_now(transaction.id).select { |s| s.product_name.eql?("Other Amount") }.last
      expect(stat.sale_item_quantity).to be(1)
    end

    it "with name 'Other Amount'" do
      stat = worker.perform_now(transaction.id).select { |s| s.product_name.eql?("Other Amount") }.last
      expect(stat.product_name).to eq("Other Amount")
    end

    it "with correct total" do
      stat = worker.perform_now(transaction.id).select { |s| s.product_name.eql?("Other Amount") }.last
      expect(stat.sale_item_total_price).to eq(15)
    end

    it "with correct unit_price" do
      stat = worker.perform_now(transaction.id).select { |s| s.product_name.eql?("Other Amount") }.last
      expect(stat.sale_item_unit_price).to eq(15)
    end
  end
end
