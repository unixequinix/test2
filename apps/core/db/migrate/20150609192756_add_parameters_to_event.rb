class AddParametersToEvent < ActiveRecord::Migration
  def change
    add_column :events, :slug, :string, index: { unique: true }
    add_column :events, :location, :string
    add_column :events, :start_date, :datetime
    add_column :events, :end_date, :datetime
    add_column :events, :description, :text
    add_column :events, :support_email, :string
    add_column :events, :style, :text
    add_attachment :events, :logo
    add_attachment :events, :background
  end
end
