class AddBannedToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :banned, :boolean
  end
end
