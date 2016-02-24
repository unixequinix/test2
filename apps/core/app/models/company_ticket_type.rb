# == Schema Information
#
# Table name: company_ticket_types
#
#  id                         :integer          not null, primary key
#  event_id                   :integer
#  company_event_agreement_id :integer
#  name                       :string
#  company_ticket_type_ref    :string
#  deleted_at                 :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class CompanyTicketType < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :event
  belongs_to :catalog_item
  belongs_to :company_event_agreement

  validates :name, :company_event_agreement, presence: true

  scope :companies, -> (event) { joins(:company).where(event: event).pluck("companies.name").uniq }

  def self.form_selector(event)
    where(event: event).map { |company_tt| [company_tt.name, company_tt.id] }
  end
end
