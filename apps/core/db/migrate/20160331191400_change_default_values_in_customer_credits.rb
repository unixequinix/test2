class ChangeDefaultValuesInCustomerCredits < ActiveRecord::Migration
  def change
    change_column_default :customer_credits, :amount, 0
    change_column_default :customer_credits, :refundable_amount, 0
    change_column_default :customer_credits, :final_balance, 0
    change_column_default :customer_credits, :final_refundable_balance, 0
  end
end
