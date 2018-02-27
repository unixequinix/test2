class RenameTopupFeeToEveryTopupFee < ActiveRecord::Migration[5.1]
  def change
    rename_column :events, :topup_fee, :every_topup_fee
  end
end
