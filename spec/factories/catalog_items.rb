# == Schema Information
#
# Table name: catalog_items
#
#  created_at      :datetime         not null
#  initial_amount  :integer
#  max_purchasable :integer
#  min_purchasable :integer
#  name            :string
#  step            :integer
#  type            :string           not null
#  updated_at      :datetime         not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

FactoryGirl.define do
  factory :catalog_item do
    event
    type { %w( Credit Access Pack ).sample }
    name { "Random name #{rand(100)}" }
    initial_amount 0
    step { rand(5) }
    max_purchasable 1
    min_purchasable 0
  end
end
