class AddReceiveCommunicationsTwoMessageToEventTranslations < ActiveRecord::Migration
  def change
    add_column :event_translations, :receive_communications_two_message, :text
  end
end
