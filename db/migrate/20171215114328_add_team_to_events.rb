class AddTeamToEvents < ActiveRecord::Migration[5.1]
  def change
    add_reference :events, :team, index: true
  end
end
