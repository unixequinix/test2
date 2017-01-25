# == Schema Information
#
# Table name: company_event_agreements
#
#
# Indexes
#
#  index_company_event_agreements_on_company_id  (company_id)
#  index_company_event_agreements_on_event_id    (event_id)
#
# Foreign Keys
#
#  fk_rails_52b6bdbbec  (company_id => companies.id)
#  fk_rails_88826edadd  (event_id => events.id)
#

class CompanyEventAgreement < ActiveRecord::Base
  belongs_to :company
  belongs_to :event
  has_many :ticket_types, dependent: :destroy

  validates :company, :event, presence: true
  validates :event, uniqueness: { scope: :company }
end
