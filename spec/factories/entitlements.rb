# == Schema Information
#
# Table name: entitlements
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :entitlement do
    name "MyString"
  end

end
