class MoveRefundsStatusToState < ActiveRecord::Migration[5.1]
  def change
    statuses = { started: 1, completed: 2, cancelled: 3 }

    statuses.each { |status, value| Refund.where(["status = ?", status]).update_all(old_status: value) }
  end
end

