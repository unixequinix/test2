# == Schema Information
#
# Table name: catalog_items
#
#  created_at      :datetime         not null
#  initial_amount  :integer
#  max_purchasable :integer
#  min_purchasable :integer
#  name            :string
#  step            :integer
#  type            :string           not null
#  updated_at      :datetime         not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

class Pack < CatalogItem
  has_many :pack_catalog_items, autosave: true, dependent: :destroy, inverse_of: :pack
  has_many :catalog_items, through: :pack_catalog_items
  accepts_nested_attributes_for :pack_catalog_items, allow_destroy: true

  scope :credentiable_packs, -> { where(catalog_items: { type: CREDENTIABLE_TYPES }) }

  validates :initial_amount, :step, :max_purchasable, :min_purchasable, presence: true
  validate :valid_max_value, if: :infinite_item?
  validate :valid_min_value, if: :infinite_item?
  validate :valid_max_credits

  def credits
    pack_catalog_items.includes(:catalog_item).where(catalog_items: { type: "Credit" }).sum(:amount)
  end

  def only_credits?
    catalog_items.all? { |item| item.is_a?(Credit) }
  end

  private

  def infinite_item?
    catalog_items.any? { |item| item.entitlement.infinite? if item.is_a?(Access) }
  end

  def valid_max_value
    return if catalog_item.max_purchasable.between?(0, 1)
    errors[:max_purchasable] << I18n.t("errors.messages.invalid_max_value_for_infinite")
  end

  def valid_min_value
    return if catalog_item.min_purchasable.between?(0, 1)
    errors[:min_purchasable] << I18n.t("errors.messages.invalid_min_value_for_infinite")
  end

  def valid_max_credits
    max_balance = event.gtag_settings["maximum_gtag_balance"].to_i
    errors[:pack_credits] << I18n.t("errors.messages.more_credits_than_max_balance") if credits > max_balance
  end
end
