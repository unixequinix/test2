class AddRememberTokenToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :remember_token, :string, index: { unique: true }
  end
end
