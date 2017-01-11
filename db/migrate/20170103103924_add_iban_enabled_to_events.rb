class AddIbanEnabledToEvents < ActiveRecord::Migration
  def change
    add_column :events, :iban_enabled, :boolean, default: true unless column_exists?(:events, :iban_enables)
  end
end
