class RenameEnviormentColumnToEnvironmentInStationTypes < ActiveRecord::Migration
  def change
    rename_column :station_types, :enviorment, :environment
  end
end
