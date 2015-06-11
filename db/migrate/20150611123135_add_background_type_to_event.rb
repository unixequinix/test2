class AddBackgroundTypeToEvent < ActiveRecord::Migration
  def change
    add_column :events, :background_type, :string, default: Event::BACKGROUND_FIXED
  end
end