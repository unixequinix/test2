class MoveCompanyIntoTicketTypes < ActiveRecord::Migration[5.1]
  def change
    sql = "SELECT id, name FROM companies"
    ActiveRecord::Base.connection.select_all(sql).rows.each do |id, name|
      TicketType.where(company_id: id).update_all(company: name)
    end
  end
end
