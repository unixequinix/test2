class AddBirthdateToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :birthdate, :datetime
  end
end
