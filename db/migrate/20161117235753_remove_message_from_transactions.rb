class RemoveMessageFromTransactions < ActiveRecord::Migration
  def change
    remove_column :transactions, :message, :string

    puts "-- removing ban transactions"
    sql = "DELETE FROM transactions TR
           WHERE TR.type = 'BanTransaction'"
    ActiveRecord::Base.connection.execute(sql)
  end
end
