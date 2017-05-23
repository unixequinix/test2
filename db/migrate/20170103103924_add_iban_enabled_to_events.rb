class AddIbanEnabledToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :iban_enabled, :boolean, default: true unless column_exists?(:events, :iban_enables)
  end
end
