FactoryBot.define do
  factory :user_flag do
    event
    sequence(:name) { |n| "Flag #{n}" }
  end
end
