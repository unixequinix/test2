# == Schema Information
#
# Table name: ticket_types
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  company         :string           not null
#  credit          :decimal(8, 2)    default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  simplified_name :string
#  event_id        :integer          not null
#

class TicketType < ActiveRecord::Base
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  belongs_to :event
  has_many :tickets, dependent: :restrict_with_error
  has_many :entitlement_ticket_types, dependent: :destroy
  has_many :entitlements, through: :entitlement_ticket_types

  accepts_nested_attributes_for :entitlements

  # Validations
  validates :name, :company, :credit, presence: true

  # Scopes
  scope :companies, -> (event) { where(event: event).pluck(:company).uniq }

  # Select options with all the entitlements
  def self.form_selector(event)
    where(event: event).map { |ticket_type| [ticket_type.name, ticket_type.id] }
  end

end
