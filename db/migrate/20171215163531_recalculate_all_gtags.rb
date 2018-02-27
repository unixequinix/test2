class RecalculateAllGtags < ActiveRecord::Migration[5.1]
  def change
    Gtag.find_by_sql("UPDATE gtags SET credits = credits - refundable_credits, final_balance = final_balance - final_refundable_balance")
  end
end
