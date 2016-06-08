class AddFormatToGtags < ActiveRecord::Migration
  def change
    add_column :gtags, :format, :string, default: "wristband"
  end
end
