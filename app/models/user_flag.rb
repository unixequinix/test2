# == Schema Information
#
# Table name: catalog_items
#
#  initial_amount  :integer
#  max_purchasable :integer
#  memory_length   :integer          default(1)
#  memory_position :integer
#  min_purchasable :integer
#  mode            :string
#  name            :string
#  step            :integer
#  type            :string           not null
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

class UserFlag < CatalogItem
end
