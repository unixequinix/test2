FactoryGirl.define do
  factory :entitlement do
    infinite { [true, false].sample }
    memory_position { rand(100) }
    memory_length { rand(1..2) }
  end
end
