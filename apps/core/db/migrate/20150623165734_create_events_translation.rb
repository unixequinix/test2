class CreateEventsTranslation < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    translates :info, :disclaimer
  end

  def up
    Event.create_translation_table! info: { type: :text, null: false },
                                    disclaimer: { type: :text, null: false }
  end

  def down
    Event.drop_translation_table!
  end
end
