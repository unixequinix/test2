class AddIbanEnabledToEvents < ActiveRecord::Migration
  def change
    add_column :events, :iban_enabled, :boolean, default: true
  end
end
