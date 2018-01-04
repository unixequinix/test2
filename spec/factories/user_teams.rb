FactoryBot.define do
  factory :user_team do
    association :team
    association :user
    leader false
  end
end
