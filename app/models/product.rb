class Product < ApplicationRecord
  belongs_to :station, touch: true
  has_many :sale_items, dependent: :restrict_with_error

  validates :name, uniqueness: { scope: :station_id, case_sensitive: false }, presence: true
  validates :price, :position, presence: true, numericality: true
  validates :vat, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  before_validation :set_position

  scope :with_name_like, ->(query) { where("lower(name) LIKE ?", "%#{sanitize_sql_like(query)}%") }

  default_scope { order(position: :asc) }

  def self.sort_column
    :position
  end

  def self.policy_class
    StationItemPolicy
  end

  private

  def set_position
    self.position = station.products.count + 1 if position.blank?
  end
end
