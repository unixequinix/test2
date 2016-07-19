# == Schema Information
#
# Table name: company_ticket_types
#
#  id                      :integer          not null, primary key
#  company_id              :integer
#  preevent_product_id     :integer
#  event_id                :integer
#  name                    :string
#  company_ticket_type_ref :string
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

FactoryGirl.define do
  factory :company_ticket_type do
    name { "Name #{rand(100)}" }
    company_code { rand(100) }
    credential_type
    event

    after(:build) do |ctt|
      ctt.company_event_agreement = create(:company_event_agreement, event: ctt.event)
    end

    after(:create) do |ctt|
      item = create(:catalog_item, :with_credit, event: ctt.event)
      ctt.credential_type = create(:credential_type, catalog_item: item)
      ctt.save
    end
  end
end
