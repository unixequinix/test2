class AddActiveToTeamInvitations < ActiveRecord::Migration[5.1]
  def change
    add_column :team_invitations, :active, :boolean, default: false
  end
end
