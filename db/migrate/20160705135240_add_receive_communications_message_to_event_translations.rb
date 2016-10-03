class AddReceiveCommunicationsMessageToEventTranslations < ActiveRecord::Migration
  def change
    add_column :event_translations, :receive_communications_message, :text
  end
end
