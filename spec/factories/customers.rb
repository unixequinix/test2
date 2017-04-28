FactoryGirl.define do
  factory :customer do
    sequence(:first_name) { |n| "FirstName #{n}" }
    sequence(:last_name) { |n| "LastName #{n}" }
    sequence(:email) { |n| "email_#{n}@glownet.com" }
    agreed_on_registration true
    password "password"
    password_confirmation "password"
    sequence(:phone) { |n| "1-800-#{n}" }
    country { %w[EN ES IT].sample }
    gender { %w[male female].sample }
    birthdate { (13..70).to_a.sample.years.ago }
    postcode { "12345" }
    agreed_event_condition true
    event
  end
end
