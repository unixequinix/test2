class RemoveCustomerCredits < ActiveRecord::Migration
  def change
    drop_table :customer_credits if table_exists?(:customer_credits)
  end
end
