class AddFeeParametersToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :gtag_deposit_fee, :integer, default: 0
    add_column :events, :topup_fee, :integer, default: 0
    add_column :events, :card_return_fee, :integer, default: 0
  end
end
