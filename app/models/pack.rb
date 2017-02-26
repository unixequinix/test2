# == Schema Information
#
# Table name: catalog_items
#
#  memory_length   :integer          default(1)
#  memory_position :integer          indexed => [event_id]
#  mode            :string
#  name            :string
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
  attr_accessor :alcohol_forbidden

  has_many :pack_catalog_items, dependent: :destroy, inverse_of: :pack
  has_many :catalog_items, through: :pack_catalog_items

  accepts_nested_attributes_for :pack_catalog_items, allow_destroy: true

  scope :credentiable_packs, -> { where(catalog_items: { type: CREDENTIABLE_TYPES }) }
  validates :pack_catalog_items, associated: true

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
    catalog_items.accesses.any?(&:infinite?)
  end
end
