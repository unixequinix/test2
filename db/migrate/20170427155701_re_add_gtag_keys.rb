class ReAddGtagKeys < ActiveRecord::Migration[5.0]
  def change
    rename_column :events, :gtag_key, :ultralight_c_private_key unless column_exists?(:events, :ultralight_c_private_key)
    add_column :events, :mifare_classic_public_key unless column_exists?(:events, :mifare_classic_public_key)
    add_column :events, :mifare_classic_private_key_a unless column_exists?(:events, :mifare_classic_private_key_a)
    add_column :events, :mifare_classic_private_key_b unless column_exists?(:events, :mifare_classic_private_key_b)
    add_column :events, :ultralight_ev1_private_key unless column_exists?(:events, :ultralight_ev1_private_key)
  end
end
