class UpdateRefundStatus < ActiveRecord::Migration[5.0]
  def change
    Refund.where(status: "PENDING").update_all(status: "started")
    Refund.where(status: "SUCCESS").update_all(status: "completed")
  end
end