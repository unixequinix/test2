FactoryBot.define do
  factory :ticket_type do
    event
    sequence(:name) { |n| "Ticket Type #{n}" }
    sequence(:company_code)
    catalog_item { build(:catalog_item, event: event) }
  end
end
