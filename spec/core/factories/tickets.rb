# == Schema Information
#
# Table name: tickets
#
#  id                     :integer          not null, primary key
#  code                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  purchaser_email        :string
#  purchaser_first_name   :string
#  purchaser_last_name    :string
#  event_id               :integer          not null
#  credential_redeemed    :boolean          default(FALSE), not null
#  company_ticket_type_id :integer          not null
#

FactoryGirl.define do
  factory :ticket do
    code { Faker::Number.number(10) }
    purchaser_email { Faker::Internet.email }
    purchaser_first_name { Faker::Name.first_name }
    purchaser_last_name { Faker::Name.last_name }
    event_id 1
    credential_redeemed { [true, false].sample }
    company_ticket_type
  end
end
