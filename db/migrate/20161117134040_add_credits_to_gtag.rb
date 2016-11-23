class AddCreditsToGtag < ActiveRecord::Migration
  def change
    add_column :gtags, :credits, :decimal, precision: 8, scale: 2
    add_column :gtags, :refundable_credits, :decimal, precision: 8, scale: 2
    add_column :gtags, :final_balance, :decimal, precision: 8, scale: 2
    add_column :gtags, :final_refundable_balance, :decimal, precision: 8, scale: 2

    puts "-- moving balances to gtag from profile"
    sql = "UPDATE gtags GT
           SET credits = PR.credits, refundable_credits = Pr.refundable_credits, final_balance = PR.final_balance, final_refundable_balance = PR.final_refundable_balance
           FROM profiles PR
           WHERE GT.profile_id = PR.id"
    ActiveRecord::Base.connection.execute(sql)
  end
end
