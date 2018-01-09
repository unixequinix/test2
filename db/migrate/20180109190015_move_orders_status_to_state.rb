class MoveOrdersStatusToState < ActiveRecord::Migration[5.1]
  def change
    statuses = { in_progress: 1, completed: 2, refunded: 3, failed: 4, cancelled: 5 }

    statuses.each { |status, value| Order.where(["status = ?", status]).update_all(old_status: value) }
  end
end
