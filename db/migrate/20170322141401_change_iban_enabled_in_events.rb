class ChangeIbanEnabledInEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :iban_enabled, :boolean, default: true
    add_column :events, :bank_format, :integer, default: 0

    Event.update_all bank_format: 0
  end
end
