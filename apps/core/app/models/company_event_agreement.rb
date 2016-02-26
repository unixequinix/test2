# == Schema Information
#
# Table name: company_event_agreements
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  event_id   :integer          not null
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CompanyEventAgreement < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :company
  belongs_to :event
  has_many :company_ticket_types, dependent: :restrict_with_error


  # Validations
  validates :company, :event, presence: true
  validates :event, uniqueness: { scope: :company }
end
