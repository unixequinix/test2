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
    standard false
    value { rand(100.00) }
    currency { %w(EUR GBP).sample }

    trait :standard do
      standard true
    end

    after(:build) do |credit|
      credit.preevent_item ||= build(:preevent_item_credit, purchasable: credit)
    end

    factory :standard_credit, traits: [:standard]
  end
end
