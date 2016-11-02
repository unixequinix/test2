class AddEventAndDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :description, :string
    add_column :products, :event_id, :integer, index: true
    change_column :products, :is_alcohol, :boolean, default: false
  end
end
