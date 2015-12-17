class AddRefundDisclaimerToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    translates :refund_disclaimer
  end

  def up
    Event.add_translation_fields! refund_disclaimer: :text
  end

  def down
    remove_column :event_translations, :refund_disclaimer
  end
end
