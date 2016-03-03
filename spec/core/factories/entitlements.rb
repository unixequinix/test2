FactoryGirl.define do
  factory :entitlement do
    unlimited { [true, false].sample }
    memory_position { rand(100) }
  end
end
