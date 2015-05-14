# == Schema Information
#
# Table name: online_products
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  description      :string           not null
#  price            :decimal(8, 2)    not null
#  purchasable_id   :integer          not null
#  purchasable_type :string           not null
#  min_purchasable  :integer
#  max_purchasable  :integer
#  initial_amount   :integer
#  step             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

FactoryGirl.define do
  factory :online_product do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    price "9.99"
  end

end
