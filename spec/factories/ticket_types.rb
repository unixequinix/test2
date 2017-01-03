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
#  fk_rails_3f5bd3dab9  (event_id => events.id)
#  fk_rails_6de81efbc5  (company_event_agreement_id => company_event_agreements.id)
#  fk_rails_b4ebebdc55  (catalog_item_id => catalog_items.id)
#

FactoryGirl.define do
  factory :ticket_type do
    sequence(:name) { |n| "Ticket Type #{n}" }
    sequence(:company_code)
    catalog_item
    event

    after(:build) do |ctt|
      ctt.company_event_agreement = create(:company_event_agreement, event: ctt.event)
    end

    after(:create) do |ctt|
      ctt.update catalog_item: create(:credit, event: ctt.event)
    end
  end
end
