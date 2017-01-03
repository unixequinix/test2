# == Schema Information
#
# Table name: sale_items
#
#  quantity              :integer
#  unit_price            :float
#
# Indexes
#
#  index_sale_items_on_credit_transaction_id  (credit_transaction_id)
#  index_sale_items_on_product_id             (product_id)
#
# Foreign Keys
#
#  fk_rails_c98e605038  (credit_transaction_id => transactions.id)
#  fk_rails_ee606308b2  (product_id => products.id)
#

class SaleItem < ActiveRecord::Base
  belongs_to :credit_transaction
  belongs_to :product
end
