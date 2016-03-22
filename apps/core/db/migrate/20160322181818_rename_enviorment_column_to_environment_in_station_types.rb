class RenameenvironmentColumnToEnvironmentInStationTypes < ActiveRecord::Migration
  def change
    rename_column :station_types, :environment, :environment
  end
end
