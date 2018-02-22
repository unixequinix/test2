require "rails_helper"

RSpec.describe Pokes::Order, type: :job do
  let(:worker) { Pokes::Order }
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:order) { create(:order, :with_credit, event: event, customer: customer) }
  let(:order_item) { order.order_items.first }
  let(:transaction) { create(:order_transaction, action: "order_redeemed", event: event, order: order, order_item_id: order_item.id) }

  it "redeems the order item" do
    expect { worker.perform_now(transaction) }.to change { order_item.reload.redeemed? }.from(false).to(true)
  end

  it "creates alert ir order is redeemed twice" do
    order_item.update(redeemed: true)
    expect(Alert).to receive(:propagate).once
    worker.perform_now(transaction)
  end

  it "touches the customer after redeeming" do
    expect { worker.perform_now(transaction) }.to change(customer.reload, :updated_at)
  end

  describe ".stat_creation" do
    let(:action) { "order_redeemed" }
    let(:name) { nil }

    include_examples "a poke"
  end

  describe "extracting catalog_item info" do
    let(:catalog_item) { order_item.catalog_item }

    include_examples "a catalog_item"

    it "ignores transaction unless order_item is found" do
      transaction.update(order_item_id: nil)
      expect(worker.perform_now(transaction)).to be_nil
    end
  end

  describe "extracting order information" do
    it "sets order to transaction order" do
      poke = worker.perform_now(transaction)
      expect(poke.order_id).to eql(transaction.order_id)
    end

    it "sets priority to transaction priority" do
      poke = worker.perform_now(transaction)
      expect(poke.priority).to eql(transaction.priority)
    end
  end
end
