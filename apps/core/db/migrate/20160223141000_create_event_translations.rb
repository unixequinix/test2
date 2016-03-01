class CreateEventTranslations < ActiveRecord::Migration
  def change
    create_table :event_translations do |t|
      t.references :event, null: false
      t.string :locale, null: false, index: true
      t.string :gtag_name
      t.text :info
      t.text :disclaimer
      t.text :refund_success_message
      t.text :mass_email_claim_notification
      t.text :gtag_assignation_notification
      t.text :gtag_form_disclaimer
      t.text :agreed_event_condition_message
      t.text :refund_disclaimer
      t.text :bank_account_disclaimer

      t.timestamps null: false
    end
  end
end
