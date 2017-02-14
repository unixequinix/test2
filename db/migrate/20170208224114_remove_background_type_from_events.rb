class RemoveBackgroundTypeFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :background_type, :string
  end
end
