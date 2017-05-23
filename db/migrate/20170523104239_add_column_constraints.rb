class AddColumnConstraints < ActiveRecord::Migration[5.1]
  def change
    change_column_null :refunds, :fee, false
  end
end
