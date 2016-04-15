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
  has_one :catalog_item, as: :catalogable, dependent: :destroy
  accepts_nested_attributes_for :catalog_item, allow_destroy: true

  scope :standard, lambda { |event|
    joins(:catalog_item).where(standard: true, catalog_items: { event_id: event.id })
  }

  # Validations
  validates :catalog_item, :currency, :value, presence: true
  validates_numericality_of :value, greater_than: 0
  validate :only_one_standard_credit

  def rounded_value
    value.round == value ? value.floor : value
  end

  private

  def only_one_standard_credit
    return unless standard?
    return unless catalog_item.event
    matches = Credit.standard(catalog_item.event)
    matches = matches.where("credits.id != ?", id) if persisted?
    errors.add(:standard, I18n.t("errors.messages.max_standard_credits")) if matches.exists?
  end
end
