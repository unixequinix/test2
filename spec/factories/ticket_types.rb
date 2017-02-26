FactoryGirl.define do
  factory :ticket_type do
    sequence(:name) { |n| "Ticket Type #{n}" }
    sequence(:company_code)
    catalog_item
    event
    company

    after(:create) do |ctt|
      ctt.update catalog_item: create(:credit, event: ctt.event)
    end
  end
end
