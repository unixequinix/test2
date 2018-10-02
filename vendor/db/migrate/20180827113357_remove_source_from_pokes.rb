class RemoveSourceFromPokes < ActiveRecord::Migration[5.1]
  def change
    remove_column :pokes, :source, :string
  end
end
