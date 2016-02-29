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
  has_many :customer_event_profiles, through: :credential_assignments
  has_one :assigned_customer_event_profile,
          -> { where(credential_assignments: { aasm_state: :assigned }) },
          class_name: "CustomerEventProfile"
  belongs_to :company_ticket_type
  has_one :banned_ticket

  accepts_nested_attributes_for :purchaser, allow_destroy: true

  # TODO: Remove comments from tickets
  # has_many :comments, as: :commentable

  # Validations
  validates :code, uniqueness: true
  validates :code, presence: true
  validates :company_ticket_type, presence: true

  scope :selected_data, lambda { |event_id|
    joins("LEFT OUTER JOIN admissions ON admissions.ticket_id = tickets.id
           AND admissions.deleted_at IS NULL")
      .joins("LEFT OUTER JOIN customer_event_profiles
              ON customer_event_profiles.id = admissions.customer_event_profile_id
              AND customer_event_profiles.deleted_at IS NULL")
      .joins("LEFT OUTER JOIN customers
              ON customers.id = customer_event_profiles.customer_id
              AND customers.deleted_at IS NULL")
      .select("tickets.*, customers.email, customers.name, customers.surname")
      .where(event: event_id)
  }

  scope :search_by_company_and_event, lambda { |company, event|
    includes(:purchaser, :company_ticket_type, company_ticket_type: [:company])
      .where(event: event, companies: { name: company })
  }

  scope :banned, lambda {
    Ticket.joins(:banned_ticket)
  }

  def ban!
    assignment = CredentialAssignment.find_by(credentiable_id: id, credentiable_type: "Ticket")
    BannedCustomerEventProfile.new(assign.customer_event_profile_id) unless assignment.nil?
    BannedTicket.create!(ticket_id: id)
  end

  def credits
    company_ticket_type.credential_type.credits if company_ticket_type.credential_type
  end
end
