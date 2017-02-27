class AddGtagFormatToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :gtag_format, :integer, default: 0, null: false
  end
end
