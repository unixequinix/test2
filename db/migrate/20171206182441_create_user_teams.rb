class CreateUserTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :user_teams do |t|
      t.integer :user_id, index: true
      t.integer :team_id, index: true
      t.boolean :leader, default: false
      t.timestamps
    end
  end
end
