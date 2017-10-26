FactoryBot.define do
  factory :topup_credit do
    station
    credit
    sequence(:amount)
  end
end
