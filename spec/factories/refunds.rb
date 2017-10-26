FactoryBot.define do
  factory :refund do
    event
    customer { build(:customer, event: event) }
    sequence(:amount)
    sequence(:fee)
    gateway "paypal"
    field_a "ES91 2100 0418 4502 0005 1332"
    field_b "BBVAESMMXXX"
  end
end
