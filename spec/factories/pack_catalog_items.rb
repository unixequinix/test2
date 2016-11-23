# == Schema Information
#
# Table name: pack_catalog_items
#
#  amount          :decimal(8, 2)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_pack_catalog_items_on_catalog_item_id  (catalog_item_id)
#  index_pack_catalog_items_on_pack_id          (pack_id)
#
# Foreign Keys
#
#  fk_rails_b4c71ddbac  (catalog_item_id => catalog_items.id)
#

FactoryGirl.define do
  factory :pack_catalog_item do
    pack
    catalog_item
    amount { rand(100) }
  end
end
