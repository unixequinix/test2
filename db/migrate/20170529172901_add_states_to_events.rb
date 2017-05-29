class AddStatesToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :open_api, :boolean, default: false
    add_column :events, :open_portal, :boolean, default: false
    add_column :events, :open_refunds, :boolean, default: false
    add_column :events, :open_topups, :boolean, default: false
    add_column :events, :open_tickets, :boolean, default: false
    add_column :events, :open_gtags, :boolean, default: false
  end
end
