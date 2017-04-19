FactoryGirl.define do
  factory :refund do
    customer
    sequence(:amount)
    sequence(:fee)
    field_a "ES91 2100 0418 4502 0005 1332"
    field_b "BBVAESMMXXX"
  end
end
