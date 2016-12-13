class AddTimezoneToEvents < ActiveRecord::Migration
  def change
    add_column :events, :timezone, :string
    Event.update_all(timezone: "Madrid")
  end
end
