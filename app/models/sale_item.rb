# == Schema Information
#
# Table name: sale_items
#
#  id                    :integer          not null, primary key
#  product_id            :integer
#  quantity              :integer
#  unit_price            :float
#  credit_transaction_id :integer
#

class SaleItem < ActiveRecord::Base
  belongs_to :parent, class_name: "Transaction", foreign_key: "transaction_id"
  belongs_to :product
end
