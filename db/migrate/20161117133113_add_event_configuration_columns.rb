class AddEventConfigurationColumns < ActiveRecord::Migration
  def change
    add_column :events, :ticket_assignation, :boolean, default: false
    add_column :events, :gtag_assignation, :boolean, default: false
    add_column :events, :registration_settings, :json
  end
end
