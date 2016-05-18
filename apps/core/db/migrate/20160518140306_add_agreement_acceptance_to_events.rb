class AddAgreementAcceptanceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :agreement_acceptance, :boolean, default: false
  end
end
