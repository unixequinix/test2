class RemoveBackupsFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :device_full_db_file_name, :string
    remove_column :events, :device_full_db_content_type, :string
    remove_column :events, :device_full_db_file_size, :integer
    remove_column :events, :device_full_db_updated_at, :datetime
    remove_column :events, :device_basic_db_file_name, :string
    remove_column :events, :device_basic_db_content_type, :string
    remove_column :events, :device_basic_db_file_size, :integer
    remove_column :events, :device_basic_db_updated_at, :datetime
  end
end
