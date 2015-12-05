class AddPostcodeToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :postcode, :string
  end
end
