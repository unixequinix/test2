class AddActivationCounterToGtags < ActiveRecord::Migration
  def change
    add_column :gtags, :activation_counter, :integer
  end
end
