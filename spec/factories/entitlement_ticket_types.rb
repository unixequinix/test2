# == Schema Information
#
# Table name: entitlement_ticket_types
#
#  id             :integer          not null, primary key
#  entitlement_id :integer
#  ticket_type_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :entitlement_ticket_type do
    
  end

end
