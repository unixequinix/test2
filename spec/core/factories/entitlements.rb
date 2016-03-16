FactoryGirl.define do
  factory :entitlement do
    infinite { [true, false].sample }
    memory_position { rand(100) }
  end
end
