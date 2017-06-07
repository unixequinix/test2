class AddDefaultToFees < ActiveRecord::Migration[5.1]
  def change
    change_column_default :refunds, :fee, 0
    Refund.where(fee: nil).update_all(fee: 0)
  end
end
