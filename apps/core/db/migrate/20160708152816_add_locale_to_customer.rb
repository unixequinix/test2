class AddLocaleToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :locale, :string, default: "en"
  end
end
