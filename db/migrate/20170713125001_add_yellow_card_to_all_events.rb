class AddYellowCardToAllEvents < ActiveRecord::Migration[5.1]
  def change
    Event.where.not(state: "closed").each do |event|
      event.stations.create! name: "Yellow Card", category: "yellow_card"
    end
  end
end
