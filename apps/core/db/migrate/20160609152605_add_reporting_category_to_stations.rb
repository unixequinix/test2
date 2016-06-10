class AddReportingCategoryToStations < ActiveRecord::Migration
  def change
    add_column :stations, :reporting_category, :string
  end
end
