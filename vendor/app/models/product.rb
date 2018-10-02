class Product < ApplicationRecord
  belongs_to :station, touch: true
  has_many :sale_items, dependent: :restrict_with_error

  validates :name, uniqueness: { scope: :station_id, case_sensitive: false }, presence: true
  validates :position, presence: true, numericality: true
  validates :vat, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  before_save :prices_fields
  before_validation :set_position

  scope :with_name_like, ->(query) { where("lower(name) LIKE ?", "%#{sanitize_sql_like(query)}%") }

  default_scope { order(position: :asc) }

  def self.sort_column
    :position
  end

  def self.policy_class
    StationItemPolicy
  end

  def price
    prices[station.event.credit.id.to_s].try(:[], "price")
  end

  private

  def set_position
    self.position = station.products.count + 1 if position.blank?
  end

  def prices_fields
    prices.keys.map do |price_id|
      self.prices = prices&.except!(price_id) if prices[price_id.to_s].blank? || prices[price_id.to_s]["price"].blank? || prices[price_id.to_s]["price"].to_d.nan?
    end
    self.price = prices[station.event.credit.id.to_s].try(:[], "price")

    return unless prices.empty?

    errors[:base] << "Error: must provide a price for this product"
    throw :abort
  end
end
