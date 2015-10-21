class AddPaymentServiceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :payment_service, :string, default: 'redsys'
  end
end