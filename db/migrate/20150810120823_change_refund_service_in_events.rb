class ChangeRefundServiceInEvents < ActiveRecord::Migration
  def change
    change_column :events, :refund_service, :string, default: 'bank_account'
  end
end