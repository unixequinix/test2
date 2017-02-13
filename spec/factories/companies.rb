# == Schema Information
#
# Table name: companies
#
#  access_token :string
#  name         :string           not null
#
# Indexes
#
#  index_companies_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_b64f18cd7d  (event_id => events.id)
#

FactoryGirl.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    event
    sequence(:access_token) { |n| "token#{n}" }
  end
end
