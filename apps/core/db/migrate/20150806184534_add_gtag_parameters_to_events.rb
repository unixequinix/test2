class AddGtagParametersToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    translates :info, :disclaimer, :refund_success_message, :mass_email_claim_notification,
               :gtag_assignation_notification, :gtag_form_disclaimer, :gtag_name
  end

  def up
    Event.add_translation_fields! mass_email_claim_notification: :text
    Event.add_translation_fields! gtag_assignation_notification: :text
    Event.add_translation_fields! gtag_form_disclaimer: :text
    Event.add_translation_fields! gtag_name: :string
    change_column :event_translations, :info, :text, null: true
    change_column :event_translations, :disclaimer, :text, null: true
  end

  def down
    remove_column :event_translations, :mass_email_claim_notification
    remove_column :event_translations, :gtag_assignation_notification
    remove_column :event_translations, :gtag_form_disclaimer
    remove_column :event_translations, :gtag_name
  end
end
