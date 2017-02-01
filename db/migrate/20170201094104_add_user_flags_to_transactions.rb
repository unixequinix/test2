class AddUserFlagsToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :user_flag, :string
    add_column :transactions, :user_flag_active, :boolean
  end
end
