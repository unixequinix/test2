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
    code { SecureRandom.hex(16).upcase.to_s }
    credential_redeemed { [true, false].sample }
    event
    company_ticket_type

    # after(:build) do |ticket|
    #   ticket.company_ticket_type = create(:company_ticket_type, event: ticket.event)
    # end

    trait :with_purchaser do
      after(:create) do |ticket|
        create(:purchaser, credentiable: ticket)
      end
    end

    trait :assigned do
      profile
    end
  end
end
