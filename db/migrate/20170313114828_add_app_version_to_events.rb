class AddAppVersionToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :app_version, :string, default: "5.7.0"
  end
end
