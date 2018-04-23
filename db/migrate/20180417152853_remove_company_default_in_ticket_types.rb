class RemoveCompanyDefaultInTicketTypes < ActiveRecord::Migration[5.1]
  def change
    change_column_default :ticket_types, :company, nil
  end
end
