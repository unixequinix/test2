class AddEveryOnlineTopupFeeToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :every_online_topup_fee, :float
    rename_column :events, :every_topup_fee, :every_onsite_topup_fee
    rename_column :events, :refund_fee, :online_refund_fee

  end
end
