class RemoveGtagNameFromEventTranslations < ActiveRecord::Migration
  def change
    remove_column :event_translations, :gtag_name, :string if column_exists?(:event_translations, :gtag_name)
  end
end
