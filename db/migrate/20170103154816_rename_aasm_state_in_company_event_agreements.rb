class RenameAasmStateInCompanyEventAgreements < ActiveRecord::Migration[5.0]
  def change
    remove_column :company_event_agreements, :aasm_state, :string if column_exists?(:company_event_agreements, :aasm_state)
  end
end
