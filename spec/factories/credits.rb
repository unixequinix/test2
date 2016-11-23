# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#  value      :decimal(8, 2)    default(1.0), not null
#  currency   :string           not null
#

FactoryGirl.define do
  factory :credit do |_param|
    event
    name { "Random name #{rand(100)}" }
    initial_amount 0
    step { rand(5) }
    max_purchasable 1
    min_purchasable 0

    value { rand(1..10) }

    trait :standard do
      value 1
    end

    factory :standard_credit, traits: [:standard]
  end
end
