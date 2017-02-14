class AddRedeemedToGtags < ActiveRecord::Migration[5.0]
  def change
    add_column :gtags, :redeemed, :boolean, default: true
  end
end
