class AddUniqueToTeamInvitations < ActiveRecord::Migration[5.1]
  def change
    add_index :team_invitations, [:user_id, :team_id],  unique: true
  end
end
