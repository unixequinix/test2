class Pack < CatalogItem
  attr_accessor :alcohol_forbidden

  has_many :pack_catalog_items, dependent: :destroy, inverse_of: :pack
  has_many :catalog_items, through: :pack_catalog_items

  accepts_nested_attributes_for :pack_catalog_items, allow_destroy: true, reject_if: proc { |att| att['amount'].blank? }

  scope(:credentiable_packs, -> { where(catalog_items: { type: CREDENTIABLE_TYPES }) })
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
