require "rails_helper"

RSpec.describe Pokes::Order, type: :job do
  let(:worker) { Pokes::Order }
  let(:event) { create(:event) }
  let(:order) { create(:order, :with_credit, event: event) }
  let(:order_item) { order.order_items.first }
  let(:transaction) { create(:order_transaction, action: "order_redeemed", event: event, order: order, order_item_id: order_item.id) }

  describe ".stat_creation" do
    let(:action) { "order_redeemed" }
    let(:name) { nil }

    include_examples "a poke"
  end

  describe "extracting catalog_item info" do
    let(:catalog_item) { order_item.catalog_item }

    include_examples "a catalog_item"

    it "ignores catalog_item if no order_item is found" do
      transaction.update(order_item_id: nil)
      poke = worker.perform_now(transaction)
      expect(poke.catalog_item_id).to be_nil
      expect(poke.catalog_item_type).to be_nil
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
