# == Schema Information
#
# Table name: ticket_types
#
#  id         :integer          not null, primary key
#  name       :string
#  company    :string
#  credit     :decimal(8, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :ticket_type do
    name "MyString"
company "MyString"
credit "9.99"
  end

end
