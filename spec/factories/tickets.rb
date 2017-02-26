FactoryGirl.define do
  factory :ticket do
    code { SecureRandom.hex(16).upcase.to_s }
    event
    ticket_type
    sequence(:purchaser_first_name) { |n| "Name #{n}" }
    sequence(:purchaser_last_name) { |n| "Lastname #{n}" }
    sequence(:purchaser_email) { |n| "fake_email@glownet#{n}.com" }
  end
end
