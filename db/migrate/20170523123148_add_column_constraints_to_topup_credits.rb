class AddColumnConstraintsToTopupCredits < ActiveRecord::Migration[5.1]
  def change
    change_column_null :topup_credits, :amount, false
    change_column_null :topup_credits, :credit_id, false
  end
end
