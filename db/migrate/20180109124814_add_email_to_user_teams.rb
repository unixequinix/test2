class AddEmailToUserTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :user_teams, :email, :string
  end
end
