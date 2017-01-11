class RenameAasmStateInCompanyEventAgreements < ActiveRecord::Migration
  def change
    remove_column :company_event_agreements, :aasm_state, :string if column_exists?(:company_event_agreements, :aasm_state)
  end
end
