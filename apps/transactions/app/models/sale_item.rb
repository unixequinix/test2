# == Schema Information
#
# Table name: sale_items
#
#  id                    :integer          not null, primary key
#  product_id            :integer
#  quantity              :integer
#  amount                :float
#  credit_transaction_id :integer
#

class SaleItem < ActiveRecord::Base
  belongs_to :credit_transaction
end
