class RemoveDescriptionFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :description, :text
  end
end
