class AddOnlineCounterToCustomerCredits < ActiveRecord::Migration
  def change
    add_column :customer_credits, :online_counter, :integer, default: 0
  end
end
