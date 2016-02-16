class AddTokenToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :token, :string
  end
end
