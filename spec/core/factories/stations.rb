FactoryGirl.define do
  factory :station do
    name { "word #{rand(100)}" }
  end
end
