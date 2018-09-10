FactoryBot.define do
  factory :team_invitation do
    association :team
    association :user
    leader false
    active false

    after(:build) do |team_invitation|
      team_invitation.email = team_invitation.user.email
    end
  end
end
