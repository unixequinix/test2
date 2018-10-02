class ClearGtagCredentialIdOnPokes < ActiveRecord::Migration[5.1]
  def change
    Poke.where(credential_type: 'Gtag').update_all(credential_id: nil)
  end
end
