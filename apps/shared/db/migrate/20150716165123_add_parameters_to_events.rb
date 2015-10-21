class AddParametersToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    translates :info, :disclaimer, :refund_success_message
  end

  def up
    Event.add_translation_fields! refund_success_message: :text
  end

  def down
    remove_column :event_translations, :refund_success_message
  end
end