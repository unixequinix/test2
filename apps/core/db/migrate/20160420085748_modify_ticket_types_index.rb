# rubocop:disable Metrics/LineLength
class ModifyTicketTypesIndex < ActiveRecord::Migration
  def change
    remove_index :company_ticket_types, name: "company_ref_event_agreement_index"
    add_index :company_ticket_types, %w(company_code company_event_agreement_id deleted_at), unique: true, name: "index_ticket_types_on_company_code_and_agreement_and_deleted_at"
  end
end
