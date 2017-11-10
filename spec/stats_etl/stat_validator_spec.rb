require 'rails_helper'

describe StatValidator do
  include StatValidator

  let(:event) { create(:event) }
  let(:sale_transaction) { create(:credit_transaction, :with_sales, action: "sale", event: event, credits: 0) }
  let(:sale_refund_transaction) { create(:credit_transaction, :with_sale_refunds, action: "sale_refund", event: event, credits: 0) }

  before(:each) do
    @sale_stats = []
    @sale_refund_stats = []

    sale_transaction.sale_items.each do |sale_item|
      @sale_stats << create(:stat, :with_sale_items, operation_transaction: sale_transaction, sale_item: sale_item)
    end

    sale_refund_transaction.sale_items.each do |sale_item|
      @sale_refund_stats << create(:stat, :with_sale_items, operation_transaction: sale_refund_transaction, sale_item: sale_item)
    end
  end

  context "validate_all methods" do
    it "should return nil error message" do
      expect(StatValidator.validate_all(@sale_stats.first)).to be(nil)
    end
  end

  it "should return an error on date validation" do
    date = event.end_date + 1.day
    expect(StatValidator.send(:validate_date, event, date)).to be(Stat.error_codes.key(0))
  end

  it "should return an error on quantity validation on sale" do
    @sale_stats.first.sale_item_quantity = -1
    expect(StatValidator.send(:validate_quantity_sale, @sale_stats.first)).to be(Stat.error_codes.key(1))
  end

  it "should return an error on quantity validation on sale refunds" do
    @sale_refund_stats.first.sale_item_quantity = 1
    expect(StatValidator.send(:validate_quantity_sale_refund, @sale_refund_stats.first)).to be(Stat.error_codes.key(1))
  end

  it "should return an error on sale validation"
end
