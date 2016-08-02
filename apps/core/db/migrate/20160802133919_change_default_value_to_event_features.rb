class ChangeDefaultValueToEventFeatures < ActiveRecord::Migration
  def change
    change_column_default :events, :features, 416
  end
end
