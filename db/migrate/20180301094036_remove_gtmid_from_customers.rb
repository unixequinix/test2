class RemoveGtmidFromCustomers < ActiveRecord::Migration[5.1]
  def change
    remove_column :customers, :gtmid, :string, :null => true
  end
end
