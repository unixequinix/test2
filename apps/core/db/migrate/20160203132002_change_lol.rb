class ChangeLol < ActiveRecord::Migration
  def change
    add_column :preevent_items, :position, :integer, null: false
  end
end
