class ChangeRedeemedDefaultFromGtags < ActiveRecord::Migration[5.0]
  def change
    change_column_default :gtags, :redeemed, false
  end
end
