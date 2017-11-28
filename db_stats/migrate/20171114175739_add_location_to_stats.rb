class AddLocationToStats < ActiveRecord::Migration[5.1]
  def change
    add_column :stats, :location, :string
  end
end
