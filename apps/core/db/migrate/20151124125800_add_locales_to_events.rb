class AddLocalesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :locales, :integer, null: false, default: 1
  end
end
