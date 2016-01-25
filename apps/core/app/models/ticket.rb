# == Schema Information
#
# Table name: tickets
#
#  id                     :integer          not null, primary key
#  code                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  purchaser_email        :string
#  purchaser_first_name   :string
#  purchaser_last_name    :string
#  event_id               :integer          not null
#  credential_redeemed    :boolean          default(FALSE), not null
#  company_ticket_type_id :integer
#

class Ticket < ActiveRecord::Base
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  belongs_to :event
  has_many :credential_assignments, as: :credentiable, dependent: :destroy
  has_one :assigned_ticket_credential,
          -> { where(aasm_state: :assigned) },
          as: :credentiable,
          class_name: "CredentialAssignment"
  has_many :customer_event_profiles, through: :credential_assignments
  has_one :assigned_customer_event_profile,
          -> { where(credential_assignments: { aasm_state: :assigned }) },
          class_name: "CustomerEventProfile"
  belongs_to :company_ticket_type
  has_one :ticket_blacklist

  # TODO: Remove comments from tickets
  # has_many :comments, as: :commentable

  # Validations
  validates :code, uniqueness: true

  scope :selected_data, lambda  { |event_id|
    joins("LEFT OUTER JOIN admissions ON admissions.ticket_id = tickets.id AND admissions.deleted_at IS NULL")
      .joins("LEFT OUTER JOIN customer_event_profiles ON customer_event_profiles.id = admissions.customer_event_profile_id AND customer_event_profiles.deleted_at IS NULL")
      .joins("LEFT OUTER JOIN customers ON customers.id = customer_event_profiles.customer_id AND customers.deleted_at IS NULL")
      .select("tickets.*, customers.email, customers.name, customers.surname")
      .where(event: event_id)
  }

  scope :search_by_company_and_event, lambda { |company, event|
    includes(:company_ticket_type, company_ticket_type: [:company])
      .where(event: event, companies: { name: company })
  }

  scope :blacklisted, lambda {
    Ticket.joins(:ticket_blacklist)
  }
end
