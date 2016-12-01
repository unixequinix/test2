# == Schema Information
#
# Table name: products
#
#  description  :string
#  is_alcohol   :boolean          default(FALSE)
#  name         :string
#  product_type :string
#  vat          :float            default(0.0)
#
# Indexes
#
#  index_products_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_ab0be0bcf2  (event_id => events.id)
#

FactoryGirl.define do
  factory :product do
    event
    name { "Product #{rand(10_000)}" }
    description { "Description #{rand(10_000)}" }
    is_alcohol { [true, false].sample }
  end
end
