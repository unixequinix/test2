class AddOnsiteRefundOnEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :onsite_refund_fee, :float
  end
end
