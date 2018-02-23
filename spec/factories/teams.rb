FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }

    transient do
      leader nil
    end

    after(:build) do |team, evaluator|
      user = evaluator.leader.presence || create(:user)
      team.team_invitations << create(:team_invitation, team: team, user: user, leader: true, active: true)
    end

    trait :with_users do
      transient do
        users nil
      end

      after(:build) do |team, evaluator|
        users = evaluator.users.presence || create_list(:user, 3)
        users.each do |user|
          create(:team_invitation, team: team, user: user, leader: false, active: true)
        end
      end
    end
  end
end
