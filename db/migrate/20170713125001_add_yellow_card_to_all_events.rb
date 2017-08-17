class AddYellowCardToAllEvents < ActiveRecord::Migration[5.1]
  def change
    Event.where.not(state: 3).each do |event|
      event.stations.find_or_create_by name: "Yellow Card", category: "yellow_card"
    end
  end
end
