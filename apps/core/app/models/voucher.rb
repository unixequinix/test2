# == Schema Information
#
# Table name: vouchers
#
#  id         :integer          not null, primary key
#  counter    :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Voucher < ActiveRecord::Base
  acts_as_paranoid

  has_one :preevent_product_unit, as: :purchasable, dependent: :destroy
  accepts_nested_attributes_for :preevent_product_unit, allow_destroy: true

  # Validations
  validates :preevent_product_unit, :counter, presence: true

end