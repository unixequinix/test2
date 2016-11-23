FactoryGirl.define do
  factory :topup_credit do
    station
    credit
    amount { rand(100) }
  end
end
