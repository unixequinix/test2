class AddErrorCodeToStats < ActiveRecord::Migration[5.1]
  def change
    add_column :stats, :error_code, :integer
  end
end
