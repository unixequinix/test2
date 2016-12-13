class AddDefaultToGtags < ActiveRecord::Migration
  def change
    Gtag.where(activation_counter: nil).update_all activation_counter: 0
    Transaction.where(activation_counter: nil).update_all activation_counter: 0
    change_column :gtags, :activation_counter, :integer, default: 1
  end
end
