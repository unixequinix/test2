# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  value      :decimal(8, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Credit < ActiveRecord::Base

  # Associations
  has_one :online_product, as: :purchasable, dependent: :destroy

  accepts_nested_attributes_for :online_product, allow_destroy: true

  # Validations
  validates :value, :online_product, presence: true

  # Select options with all the credits
  def self.form_selector
    all.map{ |credit| [credit.name, credit.id] }
  end
end
