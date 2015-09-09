# == Schema Information
#
# Table name: ticket_types
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  company         :string           not null
#  credit          :decimal(8, 2)    default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  simplified_name :string
#  event_id        :integer          not null
#

FactoryGirl.define do
  factory :ticket_type do
    name { Faker::Lorem.word }
    company { Faker::Lorem.word }
    credit 9.99
    simplified_name { Faker::Lorem.word }
    event

    transient do
      posts_count 5
    end

    after(:build) do |ticket_type, evaluator|
      ticket_type.entitlements <<
        FactoryGirl.build_list(:entitlement, evaluator.posts_count)
    end


  end
end
