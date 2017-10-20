class RemoveDirectionFromStats < ActiveRecord::Migration[5.1]
  def change
    remove_column :stats, :direction, :string
    remove_column :stats, :direction_counter, :string
  end
end
