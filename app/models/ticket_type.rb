# == Schema Information
#
# Table name: ticket_types
#
#  company_code    :string
#  name            :string
#
# Indexes
#
#  index_ticket_types_on_catalog_item_id  (catalog_item_id)
#  index_ticket_types_on_company_id       (company_id)
#  index_ticket_types_on_event_id         (event_id)
#
# Foreign Keys
#
#  fk_rails_46208a732b  (event_id => events.id)
#  fk_rails_4abbce3a9c  (catalog_item_id => catalog_items.id)
#  fk_rails_db490f924c  (company_id => companies.id)
#

class TicketType < ActiveRecord::Base
  has_many :tickets, dependent: :destroy

  belongs_to :event
  belongs_to :catalog_item
  belongs_to :company

  validates :name, :company_id, presence: true
  validates :company_code, uniqueness: { scope: :company_id }, allow_blank: true

  scope :for_devices, -> { where.not(catalog_item_id: nil) }
  scope :no_catalog_item, -> { where(catalog_item_id: nil) }

  def hide!
    update(hidden: true)
  end

  def show!
    update(hidden: false)
  end
end
