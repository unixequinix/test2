class DropTransactions < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.connection.execute("drop table sale_items")
    ActiveRecord::Base.connection.execute("drop table transactions")
  end
end
