class AddTipsToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :tips_enabled, :boolean, default: false
  end
end
