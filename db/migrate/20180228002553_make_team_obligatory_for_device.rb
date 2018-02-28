class MakeTeamObligatoryForDevice < ActiveRecord::Migration[5.1]
  def change
    change_column_null :devices, :team_id, false
  end
end
