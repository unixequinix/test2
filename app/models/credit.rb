class Credit < CatalogItem
  belongs_to :event

  validates :value, numericality: { greater_than: 0 }
  validates :symbol, presence: true

  after_save :set_customer_portal_price

  def full_description
    "1 #{name} = #{value} #{event.currency}"
  end

  def credits
    1
  end

  def credits_for(crd = [])
    crd = [crd].flatten
    in?(crd) ? 1 : 0
  end

  private

  def set_customer_portal_price
    station_catalog_items.update_all(price: value)
  end
end
