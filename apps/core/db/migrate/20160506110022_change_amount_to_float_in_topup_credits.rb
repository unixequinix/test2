class ChangeAmountToFloatInTopupCredits < ActiveRecord::Migration
  def change
    change_column :topup_credits, :amount, :float
  end
end
