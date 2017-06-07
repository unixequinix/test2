class Ticket < ApplicationRecord
  include Credentiable
  include Alertable

  belongs_to :ticket_type

  validates :code, uniqueness: { scope: :event_id }, presence: true
  validates :ticket_type_id, presence: true

  scope(:query_for_csv, ->(event) { event.tickets.select("tickets.*, ticket_types.name as ticket_type_name").joins(:ticket_type) })
  scope(:banned, -> { where(banned: true) })

  alias_attribute :reference, :code
  alias_attribute :ticket_reference, :code
  alias_attribute :name, :code

  def name
    "Ticket: #{code}"
  end

  def assign_gtag
    return unless customer
    gtag = event.transactions.credential.find_by(status_code: 0, action: "ticket_checkin", ticket_id: id)&.gtag
    claim_credential(gtag)
  end

  def full_name
    "#{purchaser_first_name} #{purchaser_last_name}"
  end

  def assignation_atts
    { ticket: self }
  end
end
