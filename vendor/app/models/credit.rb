class Credit < CatalogItem
  belongs_to :event

  validates :value, numericality: { greater_than: 0 }
  validates :symbol, presence: true
  validates :position, presence: true, numericality: { smaller_than_or_equal_to: Event::MAX_CREDITS }

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
end
