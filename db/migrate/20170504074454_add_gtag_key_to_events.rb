class AddGtagKeyToEvents < ActiveRecord::Migration[5.0]
  def change
    rename_column :events, :ultralight_c_private_key, :gtag_key unless column_exists?(:events, :gtag_key)

    remove_column :events, :mifare_classic_public_key, :string if column_exists?(:events, :mifare_classic_public_key)
    remove_column :events, :mifare_classic_private_key_a, :string if column_exists?(:events, :mifare_classic_private_key_a)
    remove_column :events, :mifare_classic_private_key_b, :string if column_exists?(:events, :mifare_classic_private_key_b)
    remove_column :events, :ultralight_ev1_private_key, :string if column_exists?(:events, :ultralight_ev1_private_key)
  end
end
