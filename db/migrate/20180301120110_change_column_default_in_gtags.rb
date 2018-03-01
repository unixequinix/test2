class ChangeColumnDefaultInGtags < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:gtags, :complete, true)
    change_column_default(:gtags, :consistent, true)
  end
end
