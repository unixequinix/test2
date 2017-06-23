class AddAnonymousToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :anonymous, :boolean, default: true

    Customer.all.update_all(anonymous: false)
  end
end
