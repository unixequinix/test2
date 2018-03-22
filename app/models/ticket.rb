class Ticket < ApplicationRecord
  include Credentiable
  include Alertable
  include Eventable

  belongs_to :ticket_type

  has_many :pokes, as: :credential, inverse_of: :credential, dependent: :restrict_with_error

  validates :code, uniqueness: { scope: :event_id }, presence: true
  validate_associations

  scope :query_for_csv, ->(event) { event.tickets.select("tickets.*, ticket_types.name as ticket_type_name").joins(:ticket_type) }
  scope :banned, -> { where(banned: true) }
  scope :redeemed, -> { where(redeemed: true) }

  alias_attribute :reference, :code

  def self.policy_class
    AdmissionPolicy
  end

  def self.online_packs(event)
    connection.select_all("
    SELECT
    1 as id,
    to_char(date_trunc('day', tickets.updated_at), 'Mon-DD') as event_day,
    to_char(date_trunc('hour', tickets.updated_at), 'Mon-DD HH24h') as date_time,
    '' as location,
    'Admin Panel' as station_type,
    'Admin Panel' as station_name,
    'initial_topup' as action,
    'ticket_credits_applied' as description,
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
    GROUP BY event_day, date_time, location, station_type, station_name, action, description, device_name, credit_name")
  end

  def self.credits_from_packs(event)
    connection.select_all("
      SELECT
        'initial_topup' as action,
        item2.name as credit_name,
        sum(i.amount) as credit_amount
      FROM tickets
        JOIN ticket_types ON tickets.ticket_type_id = ticket_types.id
        JOIN catalog_items item ON ticket_types.catalog_item_id = item.id
        JOIN pack_catalog_items i ON item.id = i.pack_id
        JOIN catalog_items item2 ON i.catalog_item_id = item2.id
        AND tickets.customer_id IS NOT NULL
        AND item.type in ('Pack')
        AND item2.type in ('Credit', 'VirtualCredit')
        AND item.event_id = #{event.id}
      GROUP BY 1,2
      HAVING  sum(i.amount) != 0")
  end

  def self.dashboard(event)
    ticket_credits = event.ticket_types.includes(:catalog_item).map { |tt| [tt.catalog_item_id, (tt.catalog_item&.credits.to_f + tt.catalog_item&.virtual_credits.to_f)] }.to_h

    {
      outstanding_credits: event.tickets.where.not(customer_id: nil).map { |t| ticket_credits[t.ticket_type_id].to_f }.sum
    }
  end

  def self.totals(event)
    credits_from_packs = Ticket.credits_from_packs(event)
    {
      credits_type: credits_from_packs,
      credit_breakage: credits_from_packs.map { |hash| hash.reject { |k, _v| k == 'action' } }
    }
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
