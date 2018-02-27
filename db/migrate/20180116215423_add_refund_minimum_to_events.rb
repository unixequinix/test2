class AddRefundMinimumToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :refund_minimum, :float
  end
end
