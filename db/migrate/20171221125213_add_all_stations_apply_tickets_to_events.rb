class AddAllStationsApplyTicketsToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :all_stations_apply_tickets, :boolean, default: false
  end
end
