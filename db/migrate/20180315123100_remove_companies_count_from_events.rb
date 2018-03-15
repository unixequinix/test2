class RemoveCompaniesCountFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :companies_count
  end
end
