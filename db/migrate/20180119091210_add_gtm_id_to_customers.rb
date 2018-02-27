class AddGtmIdToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :gtmid, :string, :null => true
  end
end
