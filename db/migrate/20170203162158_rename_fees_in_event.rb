class RenameFeesInEvent < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :gtag_deposit_fee, :integer
    rename_column :events, :card_return_fee, :initial_topup_fee
    rename_column :events, :gtag_deposit, :gtag_deposit_fee
    change_column :events, :initial_topup_fee, :integer, default: 0

    Event.find_by_sql("UPDATE events SET initial_topup_fee = 0")
  end
end
