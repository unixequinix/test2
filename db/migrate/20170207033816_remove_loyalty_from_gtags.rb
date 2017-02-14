class RemoveLoyaltyFromGtags < ActiveRecord::Migration[5.0]
  def change
    remove_column :gtags, :loyalty, :boolean
  end
end
