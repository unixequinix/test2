class AddStateToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :old_status, :integer, default: 1
  end
end

