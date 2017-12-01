FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "Username#{i}" }
    sequence(:email) { |n| "email@#{n}domain.com" }
    password "gl0wn3T"
    password_confirmation "gl0wn3T"
  end
end
