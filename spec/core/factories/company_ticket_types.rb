# == Schema Information
#
# Table name: company_ticket_types
#
#  id                      :integer          not null, primary key
#  company_id              :integer
#  preevent_product_id     :integer
#  event_id                :integer
#  name                    :string
#  company_ticket_type_ref :string
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

FactoryGirl.define do
  factory :company_ticket_type do
    event
    name { "Name #{rand(100)}" }
    company_ticket_type_ref { rand(5) }
    company_event_agreement
    credential_type
  end
end
