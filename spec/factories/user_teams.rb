FactoryBot.define do
  factory :user_team do
    association :team
    association :user
    leader false

    after(:build) do |user_team|
      user_team.email = user_team.user.email
    end
  end
end
