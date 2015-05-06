# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  name       :string
#  aasm_state :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :event do
    name "MyString"
aasm_state "MyString"
  end

end
