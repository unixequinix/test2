class AddIndexToMemoryPosition < ActiveRecord::Migration[5.0]
  def change
    Event.where(state: ["closed"]).each do |event|
      event.catalog_items.accesses.each.with_index { |access, index| access.update! memory_position: index }
    end
    add_index :catalog_items, [:memory_position, :event_id], unique: true
  end
end
