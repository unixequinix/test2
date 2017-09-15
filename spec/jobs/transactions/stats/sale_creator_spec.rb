require "rails_helper"

RSpec.describe Transactions::Stats::SaleCreator, type: :job do
  let(:worker) { Transactions::Stats::SaleCreator }
  let(:event) { create(:event) }
  let(:product) { create(:product) }
  let(:transaction) { create(:credit_transaction, action: "sale", event: event) }
  let(:atts) { { transaction_id: transaction.id } }

  before { 3.times { |_i| transaction.sale_items.create! product_id: product.id, unit_price: 2, quantity: 3 } }

  it "creates one Stat per sale item" do
    expect { worker.perform_now(atts) }.to change(Stat, :count).by(transaction.sale_items.size)
  end

  it "creates stats with payment_method credits" do
    worker.perform_now(atts)
    payment_methods = Stat.where(event: event, transaction_id: transaction.id).pluck(:payment_method).uniq
    expect(payment_methods.size).to be(1)
    expect(payment_methods.last).to eq("credits")
  end

  describe "Other amounts" do
    before { transaction.update other_amount_credits: 10 }
    let(:stat) { Stat.find_by(event: event, transaction_id: transaction.id, transaction_counter: 0) }

    it "creates one Stat for other amount if present" do
      expect { worker.perform_now(atts) }.to change(Stat, :count).by(transaction.sale_items.size + 1)
    end

    it "with positive quantity if action is sale" do
      worker.perform_now(atts)
      expect(stat.product_qty).to be(1)
    end

    it "with negative quantity if action is anything else" do
      transaction.update action: "anything_else"
      worker.perform_now(atts)
      expect(stat.product_qty).to be(-1)
    end

    it "with name 'Other Product'" do
      worker.perform_now(atts)
      expect(stat.product_name).to eq("Other Product")
    end

    it "with correct total" do
      worker.perform_now(atts)
      expect(stat.total).to eq(transaction.other_amount_credits)
    end
  end
end
