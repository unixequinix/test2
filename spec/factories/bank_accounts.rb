# == Schema Information
#
# Table name: bank_accounts
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  iban        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  swift       :string
#

FactoryGirl.define do
  factory :bank_account do
    number "MyString"
  end

end
