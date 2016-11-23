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
#  fk_rails_ee606308b2  (product_id => products.id)
#

require "spec_helper"

RSpec.describe SaleItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
