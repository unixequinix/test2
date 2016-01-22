class AddPreeventItemsCountToPreeventProducts < ActiveRecord::Migration
  def self.up
    add_column :preevent_products, :preevent_items_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :preevent_products, :preevent_items_count
  end
end
