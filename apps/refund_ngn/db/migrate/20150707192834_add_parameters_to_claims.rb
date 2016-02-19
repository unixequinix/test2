class AddParametersToClaims < ActiveRecord::Migration
  def change
    add_reference :claims, :gtag, index: true, foreign_key: true
    add_column :claims, :service_type, :string
  end
end
