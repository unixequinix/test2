FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }

    transient do
      leader nil
    end

    after(:build) do |team, evaluator|
      user = evaluator.leader.blank? ? create(:user) : evaluator.leader
      team.user_teams << create(:user_team, team: team, user: user, leader: true)
    end

    trait :with_users do
      transient do
        users nil
      end

      after(:build) do |team, evaluator|
        users = evaluator.users.blank? ? create_list(:user, 3) : evaluator.users
        users.each do |user|
          create(:user_team, team: team, user: user, leader: false)
        end
      end
    end
  end
end
