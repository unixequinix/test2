class RemoveTokenFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :token, :string, null: false
  end
end
