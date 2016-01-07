FactoryGirl.define do
  factory :preevent_product do
    name { Faker::Number.between(1, 20) }
    online { [true,false].sample }
    event
  end
end
