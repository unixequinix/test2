# == Schema Information
#
# Table name: entitlement_ticket_types
#
#  id             :integer          not null, primary key
#  entitlement_id :integer          not null
#  ticket_type_id :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#

FactoryGirl.define do
  factory :entitlement_ticket_type do
    entitlement
    ticket_type
  end
end
