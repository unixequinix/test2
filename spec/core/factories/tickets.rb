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
    event
    credential_redeemed { [true, false].sample }
    company_ticket_type

    trait :banned do
      after(:create) do |ticket|
        create(:banned_ticket, ticket: ticket)
      end
    end

    trait :with_purchaser do
      after(:build) do |ticket|
        create :purchaser, credentiable: ticket
      end
    end
  end
end
