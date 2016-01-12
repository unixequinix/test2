# == Schema Information
#
# Table name: companies_ticket_types
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  name       :string
#  company    :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CompaniesTicketType < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :event
  has_many :ticket_type_credentials
  has_many :preevent_products,
    through: :ticket_type_credentials,
    class_name: 'PreeventProduct'
end
=begin
  source: :purchasable,
  source_type: 'CredentialType',
   Try 'has_many :credentials, :through => :ticket_type_credentials, :source => <name>'. Is it one of company_ticket_type or Preevent_product?

=end
