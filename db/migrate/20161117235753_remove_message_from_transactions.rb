class RemoveMessageFromTransactions < ActiveRecord::Migration
  def change
    puts "-- removing ban transactions"
    sql = "DELETE FROM transactions TR
           WHERE TR.type = 'BanTransaction'"
    ActiveRecord::Base.connection.execute(sql)
  end
end
