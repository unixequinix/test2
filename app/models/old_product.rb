class OldProduct < ApplicationRecord
  belongs_to :event
  has_many :sale_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: { scope: :event_id, case_sensitive: false }

  scope :with_name_like, ->(query) { where("lower(name) LIKE ?", "%#{sanitize_sql_like(query)}%") }
end
