class AddNameIndexToCompaniesName < ActiveRecord::Migration[5.0]
  def change
    add_index :companies, [:event_id, :name], unique: true
  end
end
