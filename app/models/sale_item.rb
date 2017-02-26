class SaleItem < ActiveRecord::Base
  belongs_to :credit_transaction
  belongs_to :product
end
