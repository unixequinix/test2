class AddFeaturesToEvent < ActiveRecord::Migration
  def change
    add_column :events, :features, :integer, null: false, default: 0
  end
end