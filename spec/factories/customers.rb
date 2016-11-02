FactoryGirl.define do
  factory :customer do
    first_name { "FirstName #{rand(100)}" }
    last_name { "LastName #{rand(100)}" }
    email { "email_#{rand(10_000)}@glownet.com" }
    agreed_on_registration true
    password "password"
    password_confirmation "password"
    phone { "1-800-#{rand(100)}" }
    country { %w( EN ES TH IT ).sample }
    gender { %w(male female).sample }
    birthdate { (13..70).to_a.sample.years.ago }
    postcode { "12345" }
    agreed_event_condition true
    event
  end
end
