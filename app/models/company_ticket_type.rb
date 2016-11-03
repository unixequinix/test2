# == Schema Information
#
# Table name: company_ticket_types
#
#  id                         :integer          not null, primary key
#  event_id                   :integer          not null
#  company_event_agreement_id :integer          not null
#  credential_type_id         :integer
#  name                       :string
#  company_code               :string
#  deleted_at                 :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class CompanyTicketType < ActiveRecord::Base
  acts_as_paranoid

  has_many :tickets, dependent: :restrict_with_error

  belongs_to :event
  belongs_to :credential_type
  belongs_to :company_event_agreement

  validates :name, :company_event_agreement, presence: true
  validates :company_code, uniqueness: { scope: :company_event_agreement }, allow_blank: true

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