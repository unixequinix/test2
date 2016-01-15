class AddBackgroundTypeToEvent < ActiveRecord::Migration
  class Event < ActiveRecord::Base
  end

  def change
    add_column :events, :background_type, :string, default: 'fixed'
  end
end
