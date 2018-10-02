class AddColorsToTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_items, :color, :string, allow: nil
  end
end
