FactoryBot.define do
  factory :refund do
    event
    customer { build(:customer, event: event, active_gtag: build(:gtag, event: event, final_balance: 200)) }
    credit_base { 10 }
    credit_fee { 0 }
    gateway { "paypal" }
    fields { { iban: "ES91 2100 0418 4502 0005 1332", swift: "BBVAESMMXXX" } }
  end
end
