FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "Username#{i}" }
    sequence(:email) { |n| "email@#{n}domain.com" }
    password "password"
    password_confirmation "password"
  end
end
