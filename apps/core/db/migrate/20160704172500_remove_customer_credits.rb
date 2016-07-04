class RemoveCustomerCredits < ActiveRecord::Migration
  def change
    add_column :profiles, :credits,                  :float, default: 0.00
    add_column :profiles, :refundable_credits,       :float, default: 0.00
    add_column :profiles, :final_balance,            :float, default: 0.00
    add_column :profiles, :final_refundable_balance, :float, default: 0.00
  end
end
