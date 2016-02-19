class TransactionSaleItem < ActiveRecord::Base
  belongs_to :monetary_transaction
  belongs_to :onsite_product
end
