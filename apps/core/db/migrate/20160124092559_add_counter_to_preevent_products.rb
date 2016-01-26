class AddCounterToPreeventProducts < ActiveRecord::Migration
  def change
    add_column :preevent_products, :preevent_items_count, :integer, null: false, default: 0
  end
end
