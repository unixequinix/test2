class RemoveOpenTicketingApiFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :open_ticketing_api, :boolean, default: false
  end
end
