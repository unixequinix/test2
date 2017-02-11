class RemoveCompanyEventAgreements < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :hidden, :boolean
    add_reference :companies, :event, foreign_key: true, index: true
    add_reference :ticket_types, :company, foreign_key: true, index: true

    ids = ActiveRecord::Base.connection.exec_query("SELECT id, event_id, company_id FROM company_event_agreements").rows
    ids.each do |id, event_id, company_id|
      event = Event.find(event_id)
      old_company = Company.find(company_id)
      new_company = Company.create!(name: old_company.name, access_token: old_company.access_token, event_id: event_id)
      tts = ActiveRecord::Base.connection.exec_query("SELECT id FROM ticket_types WHERE ticket_types.company_event_agreement_id = #{id}").rows.flatten
      tts.each { |id| TicketType.find(id).update!(company_id: new_company.id) }
      (event.ticket_types - TicketType.find(tts)).each { |tt| tt.update_attribute(:company_id, event.companies.find_or_create_by!(name: "Glownet").id) }
    end

    remove_reference :ticket_types, :company_event_agreement, foreign_key: true, index: true
    ActiveRecord::Base.connection.exec_query("DELETE FROM company_event_agreements")
    Company.where(event_id: nil).destroy_all
    drop_table :company_event_agreements
  end
end
