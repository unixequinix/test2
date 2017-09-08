FactoryGirl.define do
  factory :ticket_type do
    event
    sequence(:name) { |n| "Ticket Type #{n}" }
    sequence(:company_code)
    catalog_item { build(:catalog_item, event: event) }
    company { build(:company, event: event) }

    after(:create) do |ctt|
      ctt.update catalog_item: create(:credit, event: ctt.event)
    end
  end
end
