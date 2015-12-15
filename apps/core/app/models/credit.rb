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
  has_one :online_product, as: :purchasable, dependent: :destroy
  accepts_nested_attributes_for :online_product, allow_destroy: true

  # Validations
  validates :online_product, presence: true
end
