class SaleItem < ApplicationRecord
  belongs_to :credit_transaction
  belongs_to :product
end
