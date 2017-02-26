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

class Credit < CatalogItem
  validates :value, numericality: { greater_than: 0 }

  after_save :set_customer_portal_price

  def full_description
    "1 #{event.credit.name} = #{value} #{event.currency}"
  end

  def credits
    1
  end

  private

  def set_customer_portal_price
    station_catalog_items.update_all(price: value)
  end
end
