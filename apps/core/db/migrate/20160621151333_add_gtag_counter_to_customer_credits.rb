class AddGtagCounterToCustomerCredits < ActiveRecord::Migration
  def change
    add_column :customer_credits, :gtag_counter, :integer
  end
end
