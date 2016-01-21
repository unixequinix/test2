class ChangeParametersInEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
  end

  def change
    Event.find_each do |event|
      event.support_email = "support@glownet.com" if event.support_email.nil?
      event.save!
    end
    change_column :events, :name, :string, null: false
    change_column :events, :slug, :string, index: { unique: true }, null: false
    change_column :events, :support_email, :string, null: false, default: "support@glownet.com"
    add_column :events, :url, :string
  end
end
