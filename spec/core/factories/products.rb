FactoryGirl.define do
  factory :product do
    is_alcohol { [true, false].sample }
  end
end
