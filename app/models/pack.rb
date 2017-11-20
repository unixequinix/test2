class Pack < CatalogItem
  attr_accessor :alcohol_forbidden

  has_many :pack_catalog_items, dependent: :destroy
  has_many :catalog_items, through: :pack_catalog_items

  scope(:credentiable_packs, -> { where(catalog_items: { type: CREDENTIABLE_TYPES }) })

  accepts_nested_attributes_for :pack_catalog_items, allow_destroy: true

  validates :pack_catalog_items, associated: true, presence: true

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
