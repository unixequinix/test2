# == Schema Information
#
# Table name: ticket_types
#
#  company_code               :string
#  name                       :string
#
# Indexes
#
#  index_ticket_types_on_catalog_item_id             (catalog_item_id)
#  index_ticket_types_on_company_event_agreement_id  (company_event_agreement_id)
#  index_ticket_types_on_event_id                    (event_id)
#
# Foreign Keys
#
#  fk_rails_46208a732b  (event_id => events.id)
#  fk_rails_4abbce3a9c  (catalog_item_id => catalog_items.id)
#  fk_rails_6f2c36d14d  (company_event_agreement_id => company_event_agreements.id)
#

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
