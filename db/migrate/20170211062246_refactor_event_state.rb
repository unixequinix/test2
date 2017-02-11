class RefactorEventState < ActiveRecord::Migration[5.0]
  def change
    states = ActiveRecord::Base.connection.exec_query("SELECT id, state FROM events").rows

    remove_column :events, :state, :string
    add_column :events, :state, :integer, default: 1

    states.each do |event_id, state|
      Event.find(event_id).update_attribute(:state, state)
    end
  end
end
