FactoryGirl.define do
  factory :topup_credit do
    station
    credit
    sequence(:amount) { |n| n }
  end
end
