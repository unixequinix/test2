# == Schema Information
#
# Table name: catalog_items
#
#  memory_length   :integer          default(1)
#  memory_position :integer          indexed => [event_id]
#  mode            :string
#  name            :string
#  type            :string           not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id                      (event_id)
#  index_catalog_items_on_memory_position_and_event_id  (memory_position,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

class UserFlag < CatalogItem
end
