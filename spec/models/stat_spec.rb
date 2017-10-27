require "rails_helper"

RSpec.describe Stat, type: :model do
  let(:event) { create(:event) }
  let(:station) { create(:station, event: event) }
  let(:sale_transaction) { create(:credit_transaction, :with_sales, action: "sale", event: event) }

  describe "stat validation" do
    before(:each) do
      sale_stats = []
      sale_transaction.sale_items.each do |sale_item|
        sale_stats << create(:stat, :with_sale_items, operation_transaction: sale_transaction, sale_item: sale_item, date: event.end_date + 1.day)
      end

      @stat = sale_stats.last
    end

    it "error code should be nil on initialize" do
      stat = build(:stat, event: event, operation_id: sale_transaction.id, date: event.end_date + 1.day)
      expect(stat.error_code).to be_nil
    end

    it "error code should not be nil after creation" do
      expect(@stat.error_code).to_not be_nil
    end
  end
end
