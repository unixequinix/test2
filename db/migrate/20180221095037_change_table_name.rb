class ChangeTableName < ActiveRecord::Migration[5.1]
  def change
    rename_table :user_teams, :team_invitations
  end
end
