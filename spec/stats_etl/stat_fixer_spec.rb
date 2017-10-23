require 'rails_helper'

describe StatFixer do
  include StatFixer

  let(:event) { create(:event) }
  let(:sale_transaction) { create(:credit_transaction, :with_sales, action: "sale", event: event) }
  let(:sale_refund_transaction) { create(:credit_transaction, :with_sale_refunds, action: "sale_refund", event: event) }

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

  describe 'fix method' do
    it 'should return a stat with a valid date'

    context 'on sale' do
      it 'should return a stat with the correct symbol of sale item quantity'
    end

    context 'on sale_refund' do
      it 'should return a stat with the correct symbol of sale item quantity'
    end

    it 'should return a stat with the correct sale item total price'
  end
end
