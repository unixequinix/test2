FactoryGirl.define do
  factory :ticket do
    event
    code { SecureRandom.hex(16).upcase.to_s }
    ticket_type { build(:ticket_type, event: event) }
    sequence(:purchaser_first_name) { |n| "Name #{n}" }
    sequence(:purchaser_last_name) { |n| "Lastname #{n}" }
    sequence(:purchaser_email) { |n| "fake_email@glownet#{n}.com" }
  end
end
