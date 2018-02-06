FactoryBot.define do
  factory :refund do
    event
    customer { build(:customer, event: event) }
    amount 10
    fee 0
    gateway "paypal"
    fields { { iban: "ES91 2100 0418 4502 0005 1332", swift: "BBVAESMMXXX" } }
  end
end
