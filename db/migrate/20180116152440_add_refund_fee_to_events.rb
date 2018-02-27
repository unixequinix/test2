class AddRefundFeeToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :refund_fee, :float
  end
end
