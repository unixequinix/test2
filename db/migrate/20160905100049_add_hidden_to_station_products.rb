class AddHiddenToStationProducts < ActiveRecord::Migration
  def change
    add_column :station_products, :hidden, :boolean, default: false
  end
end
