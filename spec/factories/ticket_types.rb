# == Schema Information
#
# Table name: ticket_types
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  company    :string           not null
#  credit     :decimal(8, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :ticket_type do
    name { Faker::Lorem.word }
    company { Faker::Lorem.word }
    credit "9.99"

    transient do
      posts_count 5
    end

    after(:build) do |ticket_type, evaluator|
      ticket_type.entitlements << FactoryGirl.build_list(:entitlement, evaluator.posts_count)
    end
  end

end
