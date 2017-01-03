class RemoveGtagNameFromEventTranslations < ActiveRecord::Migration
  def change
    remove_column :event_translations, :gtag_name, :string
  end
end
