# == Schema Information
#
# Table name: tickets
#
#  id                     :integer          not null, primary key
#  event_id               :integer          not null
#  company_ticket_type_id :integer          not null
#  code                   :string
#  credential_redeemed    :boolean          default(FALSE), not null
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  banned                 :boolean          default(FALSE)
#

class Ticket < ActiveRecord::Base
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  belongs_to :event
  has_many :credential_assignments, as: :credentiable, dependent: :destroy
  has_one :purchaser, as: :credentiable, dependent: :destroy
  has_one :assigned_ticket_credential,
          -> { where(aasm_state: :assigned) },
          as: :credentiable,
          class_name: "CredentialAssignment"
  has_many :profiles, through: :credential_assignments
  has_one :assigned_profile,
          -> { where(credential_assignments: { aasm_state: :assigned }) },
          through: :assigned_ticket_credential,
          source: :profile
  belongs_to :company_ticket_type

  accepts_nested_attributes_for :purchaser, allow_destroy: true

  # Validations
  validates :code, uniqueness: { scope: :event_id }
  validates :code, presence: true
  validates :company_ticket_type_id, presence: true

  scope :query_for_csv, lambda { |event|
    event.tickets.select("tickets.id, tickets.event_id, tickets.company_ticket_type_id as ticket_type_id,
                          company_ticket_types.name as ticket_type_name, tickets.code, tickets.banned,
                          tickets.credential_redeemed")
         .joins(:company_ticket_type)
  }

  def pack_catalog_items_included
    company_ticket_type.credential_type.catalog_item.catalogable.pack_catalog_items
  end

  def credential_type_item
    company_ticket_type.credential_type.catalog_item
  end

  def credits
    company_ticket_type.credential_type.credits if company_ticket_type.credential_type
  end
end
