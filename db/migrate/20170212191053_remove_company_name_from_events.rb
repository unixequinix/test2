class RemoveCompanyNameFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :company_name, :string
  end
end
