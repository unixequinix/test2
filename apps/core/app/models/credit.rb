# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class Credit < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_one :preevent_product_unit, as: :purchasable, dependent: :destroy
  accepts_nested_attributes_for :preevent_product_unit, allow_destroy: true

  # Validations
  validates :preevent_product_unit, presence: true
end
