class ChangeFeeColumns < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :topup_fee, :float
    change_column :events, :initial_topup_fee, :float
    change_column :events, :gtag_deposit_fee, :float
  end
end
