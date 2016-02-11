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
#  currency   :string
#

class Credit < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_one :preevent_item, as: :purchasable, dependent: :destroy
  accepts_nested_attributes_for :preevent_item, allow_destroy: true

  scope :standard_credit_preevent_product, lambda { |event|
    joins(preevent_item: :preevent_products)
    .find_by(standard: true,
             preevent_items: { purchasable_type: "Credit", event_id: event.id },
             preevent_products: { preevent_items_count: 1, event_id: event.id })
  }

  scope :standard_credit, -> { find_by(standard: true) }

  scope :with_gtag, lambda { |event|
    joins(:gtag_registrations).where(event: event, gtag_registrations: { aasm_state: :assigned })
  }

  scope :for_event, lambda { |event|
    includes(:preevent_item).where(preevent_items: { event_id: event.id })
  }

  # Validations
  validates :preevent_item, presence: true
  validate :only_one_standard_credit

  def rounded_value
    value.round == value ? value.floor : value
  end

  private

  def only_one_standard_credit
    return unless standard?
    event_id = preevent_item.event_id
    event_standard_credit = Credit.joins(:preevent_item)
                            .find_by(standard: true, preevent_items: { event_id: event_id })
    errors.add(:standard,
               I18n.t("errors.messages.max_standard_credits")) if event_standard_credit.present?
  end
end
