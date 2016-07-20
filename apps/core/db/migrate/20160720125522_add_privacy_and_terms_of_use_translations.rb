class AddPrivacyAndTermsOfUseTranslations < ActiveRecord::Migration
  def change
    add_column :event_translations, :privacy_policy, :text
    add_column :event_translations, :terms_of_use, :text
  end
end
