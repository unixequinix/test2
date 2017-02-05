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
#  fk_rails_46208a732b  (event_id => events.id)
#  fk_rails_4abbce3a9c  (catalog_item_id => catalog_items.id)
#  fk_rails_6f2c36d14d  (company_event_agreement_id => company_event_agreements.id)
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
end
