class ReanmeAllStationsApplyTicketsToStationsApplyTicketsInEvents < ActiveRecord::Migration[5.1]
  def change
    rename_column :events, :all_stations_apply_tickets, :stations_apply_tickets
  end
end
