# == Schema Information
#
# Table name: ticket_types
#
#  company_code               :string
#  name                       :string
#
# Indexes
#
#  index_ticket_types_on_catalog_item_id             (catalog_item_id)
#  index_ticket_types_on_company_event_agreement_id  (company_event_agreement_id)
#  index_ticket_types_on_event_id                    (event_id)
#
# Foreign Keys
#
#  fk_rails_3f5bd3dab9  (event_id => events.id)
#  fk_rails_6de81efbc5  (company_event_agreement_id => company_event_agreements.id)
#  fk_rails_b4ebebdc55  (catalog_item_id => catalog_items.id)
#

class TicketType < ActiveRecord::Base
  has_many :tickets, dependent: :destroy

  belongs_to :event
  belongs_to :catalog_item
  belongs_to :company_event_agreement

  validates :name, :company_event_agreement, presence: true
  validates :company_code, uniqueness: { scope: :company_event_agreement }, allow_blank: true

  scope :for_devices, -> { where.not(catalog_item_id: nil) }
  scope :companies, lambda { |_event|
    joins(company_event_agreement: :company)
      .where(company_event_agreements: { event_id: Event.first.id })
      .uniq.pluck("companies.name")
  }

  def hide!
    update(hidden: true)
  end

  def show!
    update(hidden: false)
  end

  def self.form_selector(event)
    where(event: event).map { |company_tt| [company_tt.name, company_tt.id] }
  end
end
