FactoryBot.define do
  factory :refund do
    event
    customer { build(:customer, event: event) }
    sequence(:amount)
    sequence(:fee)
    gateway "paypal"
    fields { { iban: "ES91 2100 0418 4502 0005 1332", swift: "BBVAESMMXXX" } }
  end
end
