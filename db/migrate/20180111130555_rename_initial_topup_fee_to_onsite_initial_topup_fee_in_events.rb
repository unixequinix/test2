class RenameInitialTopupFeeToOnsiteInitialTopupFeeInEvents < ActiveRecord::Migration[5.1]
  def change
    rename_column :events, :initial_topup_fee, :onsite_initial_topup_fee
    add_column :events, :online_initial_topup_fee, :float
    change_column_null :events, :onsite_initial_topup_fee, true
    change_column_null :events, :topup_fee, true
    change_column_null :events, :gtag_deposit_fee, true
    change_column_default :events, :onsite_initial_topup_fee, to: nil, from: 0.00
    change_column_default :events, :topup_fee, to: nil, from: 0.00
    change_column_default :events, :gtag_deposit_fee, to: nil, from: 0.00
    add_column :customers, :initial_topup_fee_paid, :boolean, default: false
  end
end
