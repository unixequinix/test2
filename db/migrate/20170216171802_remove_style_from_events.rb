class RemoveStyleFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :style, :text
  end
end
