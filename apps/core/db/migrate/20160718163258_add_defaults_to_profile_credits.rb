class AddDefaultsToProfileCredits < ActiveRecord::Migration
  def change
    change_column :profiles, :credits,                  :decimal, precision: 8, scale: 2, default: 0.00
    change_column :profiles, :refundable_credits,       :decimal, precision: 8, scale: 2, default: 0.00
    change_column :profiles, :final_balance,            :decimal, precision: 8, scale: 2, default: 0.00
    change_column :profiles, :final_refundable_balance, :decimal, precision: 8, scale: 2, default: 0.00
  end
end
