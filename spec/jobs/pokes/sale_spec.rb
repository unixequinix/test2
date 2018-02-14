require "rails_helper"

RSpec.describe Pokes::Sale, type: :job do
  let(:worker) { Pokes::Sale }
  let(:event) { create(:event) }
  let(:product) { create(:product) }
  let(:transaction) { create(:credit_transaction, action: "sale", event: event) }
  let(:payment) { { event.credit.id.to_s => { "amount" => 11, "unit_price" => 12, "credit_value" => event.credit.value } } }
  let(:virtual_payment) { { event.virtual_credit.id.to_s => { "amount" => 10, "unit_price" => 12, "credit_value" => event.virtual_credit.value } } }

  before do
    3.times do
      payments = payment.merge(virtual_payment)
      transaction.sale_items.create! product_id: product.id, quantity: 3, standard_unit_price: 12, standard_total_price: 36, payments: payments
    end
  end

  describe "action and description" do
    it "sets action to sale always" do
      transaction.update! action: "sale_refund"
      expect(worker.perform_now(transaction).map(&:action).uniq).to eq(["sale"])
    end

    it "sets description to action on normal items" do
      description = worker::TRIGGERS.sample
      transaction.update! action: description
      expect(worker.perform_now(transaction).map(&:description).uniq).to eq([description])
    end

    it "sets the description to other_amount on sale_items with no product and type 'other_amount'" do
      transaction.sale_items.update_all(sale_item_type: "other_amount")
      poke = [worker.perform_now(transaction)].flatten.first
      expect(poke.description).to eq("other_amount")
    end

    it "sets the description to tip on sale_items with no product and type 'tip'" do
      transaction.sale_items.update_all(sale_item_type: "tip")
      poke = [worker.perform_now(transaction)].flatten.first
      expect(poke.description).to eq("tip")
    end
  end

  it "creates one Poke per payment of sale item" do
    expect { worker.perform_now(transaction) }.to change(Poke, :count).by(6)
  end

  it "provides line_counters for every poke" do
    stats = worker.perform_now(transaction)
    expect(stats.pluck(:line_counter).sort).to eq([1, 2, 3, 4, 5, 6])
  end

  describe "extracting credit values" do
    before { transaction.update! payments: payment }

    include_examples "a credit"

    it "sets credit_amount to negative of sale_item" do
      poke = [worker.perform_now(transaction)].flatten.first
      expect(poke.credit_amount).to eql(-transaction.sale_items.first.payments[poke.credit_id.to_s][:amount])
    end
  end

  describe "extracting sale_item values" do
    before { @poke = [worker.perform_now(transaction)].flatten.first }

    it "sets product_id to one of sale_item" do
      expect(@poke.product_id).to eql(product.id)
    end

    it "sets sale_item_quantity to one of sale_item" do
      expect(@poke.sale_item_quantity).to eql(3)
    end

    it "sets sale_item_unit_price to one of sale_item" do
      expect(@poke.sale_item_unit_price).to eql(12)
    end

    it "sets standard_total_price to one of sale_item" do
      expect(@poke.standard_total_price).to eql(36)
    end
  end

  describe "extracting payments values" do
    before { @poke = [worker.perform_now(transaction)].flatten.first }

    it "sets credit_amount to one of sale_item" do
      expect(@poke.credit_amount).to eql(-11)
    end

    it "sets final_balance to one of transaction" do
      expect(@poke.credit_amount).to eql(-11)
    end
  end
end
