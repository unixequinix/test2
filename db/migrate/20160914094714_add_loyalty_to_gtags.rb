class AddLoyaltyToGtags < ActiveRecord::Migration
  def change
    add_column :gtags, :loyalty, :boolean, default: false
  end
end
