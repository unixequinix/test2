class AddBankAccountDisclaimerToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    translates :bank_account_disclaimer
  end

  def up
    Event.add_translation_fields! bank_account_disclaimer: :text
  end

  def down
    remove_column :event_translations, :bank_account_disclaimer
  end
end
