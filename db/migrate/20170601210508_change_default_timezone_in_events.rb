class ChangeDefaultTimezoneInEvents < ActiveRecord::Migration[5.1]
  def change
    change_column_default :events, :timezone, 'Madrid'
  end
end
