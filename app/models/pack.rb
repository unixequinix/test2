# == Schema Information
#
# Table name: catalog_items
#
#  initial_amount  :integer
#  max_purchasable :integer
#  memory_length   :integer
#  memory_position :integer
#  min_purchasable :integer
#  mode            :string
#  name            :string
#  step            :integer
#  type            :string           not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id                      (event_id)
#  index_catalog_items_on_memory_position_and_event_id  (memory_position,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

class Pack < CatalogItem
  has_many :pack_catalog_items, dependent: :destroy, inverse_of: :pack
  has_many :catalog_items, through: :pack_catalog_items

  accepts_nested_attributes_for :pack_catalog_items, allow_destroy: true

  scope :credentiable_packs, -> { where(catalog_items: { type: CREDENTIABLE_TYPES }) }

  validates :initial_amount, :step, :max_purchasable, :min_purchasable, presence: true
  validates :pack_catalog_items, associated: true

  validate :valid_max_value, if: :infinite_item?
  validate :valid_min_value, if: :infinite_item?

  def credits
    pack_catalog_items.includes(:catalog_item).where(catalog_items: { type: "Credit" }).sum(:amount)
  end

  def only_infinite_items?
    catalog_items.all? { |item| item.is_a?(Access) && item.infinite? }
  end

  def only_credits?
    catalog_items.all? { |item| item.is_a?(Credit) }
  end

  private

  def infinite_item?
    catalog_items.any?(&:infinite?)
  end

  def valid_max_value
    return if max_purchasable.between?(0, 1)
    errors[:max_purchasable] << I18n.t("errors.messages.invalid_max_value_for_infinite")
  end

  def valid_min_value
    return if min_purchasable.between?(0, 1)
    errors[:min_purchasable] << I18n.t("errors.messages.invalid_min_value_for_infinite")
  end
end
