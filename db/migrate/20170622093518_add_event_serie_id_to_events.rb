class AddEventSerieIdToEvents < ActiveRecord::Migration[5.1]
  def change
    add_reference :events, :event_serie, index: false
  end
end
