# == Schema Information
#
# Table name: company_event_agreements
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  event_id   :integer          not null
#  aasm_state :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CompanyEventAgreement < ActiveRecord::Base
  belongs_to :company
  belongs_to :event
  has_many :company_ticket_types, dependent: :restrict_with_error

  # State machine
  include AASM

  aasm do
    state :granted, initial: true
    state :revoked

    event :grant do
      transitions from: :revoked, to: :granted
    end

    event :revoke do
      transitions from: :granted, to: :revoked
    end
  end

  # Validations
  validates :company, :event, presence: true
  validates :event, uniqueness: { scope: :company }
end
