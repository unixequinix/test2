class AddHiddenToTopupCredits < ActiveRecord::Migration
  def change
    add_column :topup_credits, :hidden, :boolean, default: false
  end
end
