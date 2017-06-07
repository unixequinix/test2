class RemoveSomeEventStates < ActiveRecord::Migration[5.1]
  def change
    Event.where(state: [3,4]).update_all(state: 2)
    Event.where(state: [5]).update_all(state: 3)
  end
end
