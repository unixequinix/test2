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
    event_id 1
    name { Faker::Name.first_name }
    company_ticket_type_ref { Faker::Number.number(5) }
    company
    preevent_product { build :preevent_product, :full }
  end
end
