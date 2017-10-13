require "rails_helper"

RSpec.describe Stats::Order, type: :job do
  let(:worker) { Stats::Order }
  let(:event) { create(:event) }
  let(:order) { create(:order, :with_credit, event: event) }
  let(:order_item) { order.order_items.first }
  let(:transaction) { create(:order_transaction, action: "order_redeemed", event: event, order: order, order_item_counter: order_item.counter) }

  describe ".stat_creation" do
    let(:action) { "order_redeemed" }
    let(:name) { nil }

    include_examples "a stat"
  end

  describe "extracting catalog_item info" do
    let(:catalog_item) { order_item.catalog_item }

    include_examples "a catalog_item"

    it "ignores catalog_item if no order_item is found" do
      transaction.update(order_item_counter: -1)
      stat = worker.perform_now(transaction.id)
      expect(stat.catalog_item_id).to be_nil
      expect(stat.catalog_item_name).to be_nil
      expect(stat.catalog_item_type).to be_nil
    end
  end

  describe "extracting order information" do
    it "sets order to transaction order" do
      stat = worker.perform_now(transaction.id)
      expect(stat.order_id).to eql(transaction.order_id)
    end

    it "sets priority to transaction priority" do
      stat = worker.perform_now(transaction.id)
      expect(stat.priority).to eql(transaction.priority)
    end
  end
end
