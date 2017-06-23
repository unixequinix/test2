class TicketType < ApplicationRecord
  has_many :tickets, dependent: :destroy
  has_many :gtags, dependent: :destroy

  belongs_to :event
  belongs_to :catalog_item, optional: true
  belongs_to :company

  validates :company_code, uniqueness: { scope: :company_id }, allow_blank: true
  validates :name, uniqueness: { scope: %i[company_id event_id], case_sensitive: false }
  validates :name, presence: true

  scope(:for_devices, -> { where.not(catalog_item_id: nil) })
  scope(:no_catalog_item, -> { where(catalog_item_id: nil) })
end
