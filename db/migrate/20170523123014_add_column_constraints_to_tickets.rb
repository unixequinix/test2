class AddColumnConstraintsToTickets < ActiveRecord::Migration[5.1]
  def change
    change_column_null :tickets, :code, false
  end
end
