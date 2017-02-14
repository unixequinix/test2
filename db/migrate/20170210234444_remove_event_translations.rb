class RemoveEventTranslations < ActiveRecord::Migration[5.0]
  def change
    drop_table :event_translations
  end
end
