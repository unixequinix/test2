class RemoveStartedAsOrderStatus < ActiveRecord::Migration[5.1]
  def change
    Order.where(status: "started").update_all(status: "in_progress")
  end
end
