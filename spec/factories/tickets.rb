# == Schema Information
#
# Table name: tickets
#
#  id             :integer          not null, primary key
#  ticket_type_id :integer
#  number         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :ticket do
    number "MyString"
  end

end
