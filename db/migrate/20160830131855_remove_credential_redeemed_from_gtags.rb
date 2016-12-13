class RemoveCredentialRedeemedFromGtags < ActiveRecord::Migration
  def change
    remove_column :gtags, :redeemed, :boolean, default: false
    remove_column :gtags, :company_ticket_type_id, :integer
  end
end
