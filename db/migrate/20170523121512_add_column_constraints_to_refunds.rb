class AddColumnConstraintsToRefunds < ActiveRecord::Migration[5.1]
  def change
    change_column_null :refunds, :gateway, false
  end
end
