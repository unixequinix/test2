class Credit < CatalogItem
  validates :value, numericality: { greater_than: 0 }
  validates :symbol, presence: true

  after_save :set_customer_portal_price

  belongs_to :event

  def full_description
    "1 #{name} = #{value} #{event.currency}"
  end

  def credits
    1
  end

  private

  def set_customer_portal_price
    station_catalog_items.update_all(price: value)
  end
end
