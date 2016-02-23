class AddAccessTokenToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :access_token, :string
  end
end
