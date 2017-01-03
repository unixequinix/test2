class RenameAasmStateInCompanyEventAgreements < ActiveRecord::Migration
  def change
    remove_column :company_event_agreements, :aasm_state, :string
  end
end
