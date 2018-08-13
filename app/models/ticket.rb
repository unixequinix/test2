class Ticket < ApplicationRecord
  include Credentiable
  include Alertable
  include Eventable

  belongs_to :ticket_type

  has_many :pokes, dependent: :restrict_with_error

  validates :code, uniqueness: { scope: :event_id }, presence: true, length: { minimum: 1, maximum: 100 }
  validate_associations

  scope :query_for_csv, ->(event, operator = false) { event.tickets.where(operator: operator).select("tickets.*, ticket_types.name as ticket_type_name").joins(:ticket_type) }

  alias_attribute :reference, :code

  def self.policy_class
    AdmissionPolicy
  end

  def credits
    ticket_type.catalog_item.try(:credits)
  end

  def virtual_credits
    ticket_type.catalog_item.try(:virtual_credits)
  end

  def self.online_packs(event)
    connection.select_all("
    SELECT
    1 as id,
    MIN(tickets.created_at) as date,
    to_char(date_trunc('day', tickets.updated_at), 'YYYY-MM-DD') as event_day,
    to_char(date_trunc('hour', tickets.updated_at), 'YYYY-MM-DD HH24h') as date_time,
    '' as location,
    'Admin Panel' as station_type,
    'Admin Panel' as station_name,
    'income' as action,
    'ticket_credits_unapplied' as description,
     NULL as device_name,
     item2.name as credit_name,
     sum(i.amount) as credit_amount
     FROM tickets
        JOIN ticket_types ON tickets.ticket_type_id = ticket_types.id
        JOIN catalog_items item ON ticket_types.catalog_item_id = item.id
        JOIN pack_catalog_items i ON item.id = i.pack_id
        JOIN catalog_items item2 ON i.catalog_item_id = item2.id
        AND tickets.customer_id IS NOT NULL
        AND item2.type in ('Credit', 'VirtualCredit')
        AND item.event_id = #{event.id}
        AND tickets.redeemed = FALSE
    GROUP BY event_day, date_time, location, station_type, station_name, action, description, device_name, credit_name")
  end

  def name
    "Ticket: #{code}"
  end

  def purchaser_full_name
    "#{purchaser_first_name} #{purchaser_last_name}"
  end

  def assignation_atts
    { ticket: self }
  end
end
