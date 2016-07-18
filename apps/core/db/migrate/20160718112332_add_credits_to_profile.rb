class AddCreditsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :credits,                  :decimal, precision: 8, scale: 2
    add_column :profiles, :refundable_credits,       :decimal, precision: 8, scale: 2
    add_column :profiles, :final_balance,            :decimal, precision: 8, scale: 2
    add_column :profiles, :final_refundable_balance, :decimal, precision: 8, scale: 2
  end
end