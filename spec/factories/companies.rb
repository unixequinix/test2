# == Schema Information
#
# Table name: companies
#
#  access_token :string
#  name         :string           not null
#

FactoryGirl.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    event

    before :create, &:generate_access_token
  end
end
