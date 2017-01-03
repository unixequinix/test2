# == Schema Information
#
# Table name: tickets
#
#  banned               :boolean          default(FALSE)
#  code                 :string
#  description          :string
#  purchaser_email      :string
#  purchaser_first_name :string
#  purchaser_last_name  :string
#  redeemed             :boolean          default(FALSE), not null
#
# Indexes
#
#  index_tickets_on_customer_id     (customer_id)
#  index_tickets_on_event_id        (event_id)
#  index_tickets_on_ticket_type_id  (ticket_type_id)
#
# Foreign Keys
#
#  fk_rails_4def87ea62  (event_id => events.id)
#  fk_rails_5685ed71b0  (customer_id => customers.id)
#  fk_rails_89217f3a4e  (ticket_type_id => ticket_types.id)
#

class Ticket < ActiveRecord::Base
  default_scope { order(:id) }

  # Associations
  belongs_to :event
  belongs_to :customer
  belongs_to :ticket_type

  has_many :transactions

  validates :code, uniqueness: { scope: :event_id }
  validates :code, presence: true
  validates :ticket_type_id, presence: true

  scope :query_for_csv, lambda { |event|
    event.tickets.select("tickets.id, tickets.event_id, tickets.ticket_type_id as ticket_type_id,
                         ticket_types.name as ticket_type_name, tickets.code, tickets.banned,
                          tickets.redeemed")
         .joins(:ticket_type)
  }

  alias_attribute :reference, :code
  alias_attribute :ticket_reference, :code
end
