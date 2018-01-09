class RemoveTeamFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :team_id, :integer
  end
end
