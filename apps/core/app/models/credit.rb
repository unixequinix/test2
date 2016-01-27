# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#  value      :decimal(8, 2)    default(1.0), not null
#  currency   :string           not null
#

class Credit < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_one :preevent_item, as: :purchasable, dependent: :destroy
  accepts_nested_attributes_for :preevent_item, allow_destroy: true
  scope :standard_credit_preevent_product, -> {
    joins(preevent_item: :preevent_products)
    .find_by(standard: true,
      preevent_items: { purchasable_type: "Credit" },
      preevent_products: { preevent_items_count: 1 })
  }

  scope :with_gtag, -> (event) { joins(:gtag_registrations).where(event: event, gtag_registrations: { aasm_state: :assigned }) }

  # Validations
  validates :preevent_item, presence: true

end