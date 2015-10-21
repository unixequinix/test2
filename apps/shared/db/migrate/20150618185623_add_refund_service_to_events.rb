class AddRefundServiceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :refund_service, :string
  end
end