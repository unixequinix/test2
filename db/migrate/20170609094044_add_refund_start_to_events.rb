class AddRefundStartToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :refunds_start_date, :datetime
    add_column :events, :refunds_end_date, :datetime
  end
end
