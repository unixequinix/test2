FactoryGirl.define do
  factory :user_flag do
    event
    name { "flag#{rand(100)}" }
  end
end
