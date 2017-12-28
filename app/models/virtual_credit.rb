class VirtualCredit < CatalogItem
  validates :value, numericality: { greater_than: 0 }
  validates :symbol, presence: true

  belongs_to :event

  def full_description
    "1 #{name} = #{value} #{event.currency}"
  end

  def virtual_credits
    1
  end
end
