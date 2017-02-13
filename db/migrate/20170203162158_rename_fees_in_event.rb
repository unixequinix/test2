class RenameFeesInEvent < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :gtag_deposit_fee, :integer if column_exists?(:events, :gtag_deposit_fee, :integer)
    remove_column :events, :card_return_fee, :integer if column_exists?(:events, :card_return_fee, :integer)
    remove_column :events, :gtag_deposit, :integer if column_exists?(:events, :gtag_deposit, :integer)

    add_column :events, :initial_topup_fee, :integer, default: 0 unless column_exists?(:events, :initial_topup_fee, :integer)
    add_column :events, :gtag_deposit_fee, :integer, default: 0 unless column_exists?(:events, :gtag_deposit_fee, :integer)

    change_column :events, :initial_topup_fee, :integer, default: 0

    Event.find_by_sql("UPDATE events SET initial_topup_fee = 0")
  end
end
