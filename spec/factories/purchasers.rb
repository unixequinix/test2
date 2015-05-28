# == Schema Information
#
# Table name: purchasers
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  surname    :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :purchaser do
    name "MyString"
surname "MyString"
email "MyString"
  end

end
