class AddEmailToUserTeams < ActiveRecord::Migration[5.1]
  def change
    add_column(:user_teams, :email, :string) unless column_exists?(:user_teams, :email)
  end
end
