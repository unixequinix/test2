FactoryBot.define do
  factory :ticketing_integration do
    event
    token { SecureRandom.hex(8).upcase }
    type { "TicketingIntegrationEventbrite" }
  end
end
