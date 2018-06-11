class TicketType < ApplicationRecord
  include Eventable

  has_many :tickets, dependent: :destroy
  has_many :gtags, dependent: :nullify
  has_many :station_ticket_types, dependent: :destroy
  has_many :stations, through: :station_ticket_types

  belongs_to :event
  belongs_to :catalog_item, optional: true
  belongs_to :ticketing_integration, optional: true

  validates :company_code, uniqueness: { scope: %i[event_id company] }, allow_blank: true
  validates :name, uniqueness: { scope: %i[event_id company ticketing_integration_id], case_sensitive: false }

  validates :name, presence: true

  validate_associations

  scope :for_devices, -> { where.not(catalog_item_id: nil) }
  scope :no_catalog_item, -> { where(catalog_item_id: nil) }
  scope :operator, -> { where(operator: true) }

  scope :checkin_rate, -> { select("name as ticket_type_name, count(tickets.id) as total_tickets, count(CASE tickets.redeemed WHEN TRUE THEN tickets.id END) as redeemed").joins(:tickets).group(:name) }

  after_update :touch_tickets

  private

  def touch_tickets
    tickets.update_all(updated_at: updated_at)
  end
end
