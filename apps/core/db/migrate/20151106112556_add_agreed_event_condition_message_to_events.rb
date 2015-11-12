class AddAgreedEventConditionMessageToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    translates :agreed_event_condition_message
  end

  def up
    Event.add_translation_fields! agreed_event_condition_message: :text
  end

  def down
    remove_column :event_translations, :agreed_event_condition_message
  end
end
