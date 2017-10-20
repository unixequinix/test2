require "rails_helper"

RSpec.describe Stats::Purchase, type: :job do
  let(:worker) { Stats::Purchase }
  let(:event) { create(:event) }
  let(:access) { create(:access, event: event) }
  let(:transaction) { create(:money_transaction, action: "box_office_purchase", event: event, catalog_item: access) }

  describe ".stat_creation" do
    let(:action) { "purchase" }
    let(:name) { nil }

    include_examples "a stat"
  end

  describe "extracting purchase information" do
    context "portal_purchase action, " do
      let(:order) { create(:order, :with_different_items, event: event) }

      before { transaction.update! action: "portal_purchase", order: order, catalog_item: nil }

      it "creates as many stats as order_items present" do
        expect { worker.perform_now(transaction.id) }.to change(Stat, :count).by(2)
      end

      it "differentiates stats by line_counter" do
        stats = worker.perform_now(transaction.id)
        expect(stats.map(&:line_counter).sort).to eql([1, 2])
      end

      it "names action purchase" do
        stats = worker.perform_now(transaction.id)
        expect(stats.map(&:action).sort).to eql(%w[purchase purchase])
      end

      it "sets monetary_quantity to 1" do
        stats = worker.perform_now(transaction.id)
        expect(stats.map(&:monetary_quantity).uniq).to eql([1])
      end

      it "sets monetary_total_price to order_item price" do
        stats = worker.perform_now(transaction.id)
        expect(stats.sum(&:monetary_total_price).to_f).to eql(order.total.to_f)
      end

      it "sets monetary_unit_price to transaction price" do
        stats = worker.perform_now(transaction.id)
        expect(stats.sum(&:monetary_unit_price).to_f).to eql(order.total.to_f)
      end
    end

    context "box_office_purchase action, " do
      before { transaction.update action: "box_office_purchase" }
      let(:catalog_item) { transaction.catalog_item }

      include_examples "a catalog_item"
      include_examples "a money"
    end

    it "sets the payment_method of the transaction" do
      transaction.update!(payment_method: "test")
      stat = worker.perform_now(transaction.id)
      expect(stat.payment_method).to eql("test")
    end

    it "sets the currency of the event" do
      stat = worker.perform_now(transaction.id)
      expect(stat.currency).to eql(event.currency)
    end
  end
end
