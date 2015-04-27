# == Schema Information
#
# Table name: orders
#
#  id                :integer          not null, primary key
#  customer_id       :integer          not null
#  online_product_id :integer          not null
#  number            :string           not null
#  amount            :decimal(8, 2)    not null
#  aasm_state        :string           not null
#  completed_at      :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :order do
    number "MyString"
amount "9.99"
  end

end
