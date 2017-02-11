class RemoveMandatoriesFromEvent < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :city_mandatory, :boolean
    remove_column :events, :country_mandatory, :boolean
    remove_column :events, :postcode_mandatory, :boolean
  end
end
