class RemoveGtagNameFromEventTranslations < ActiveRecord::Migration[5.0]
  def change
    remove_column :event_translations, :gtag_name, :string if column_exists?(:event_translations, :gtag_name)
  end
end
