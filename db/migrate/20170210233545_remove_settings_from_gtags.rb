class RemoveSettingsFromGtags < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :gtag_format, :string, default: "standard"
  end
end
