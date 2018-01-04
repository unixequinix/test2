class AddTeamToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :team_id, :integer
  end
end
