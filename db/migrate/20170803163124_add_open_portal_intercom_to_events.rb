class AddOpenPortalIntercomToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :open_portal_intercom, :boolean, default: false
  end
end
