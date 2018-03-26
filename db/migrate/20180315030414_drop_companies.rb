class DropCompanies < ActiveRecord::Migration[5.1]
  def change
    remove_column :pokes, :company_id
    remove_column :ticket_types, :company_id
    drop_table :companies
  end
end
