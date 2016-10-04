class AddDefaultValueToEventFeatures < ActiveRecord::Migration
  def change
    change_column_default :events, :features, 32
  end
end
