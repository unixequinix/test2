# == Schema Information
#
# Table name: transaction_sale_items
#
#  id                      :integer          not null, primary key
#  onsite_product_id       :integer
#  quantity                :integer
#  total_price_paid        :float
#  monetary_transaction_id :integer
#

class TransactionSaleItem < ActiveRecord::Base
  belongs_to :monetary_transaction
  belongs_to :onsite_product
end
