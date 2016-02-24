class ProductVoucher < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :product
  belongs_to :voucher
end
