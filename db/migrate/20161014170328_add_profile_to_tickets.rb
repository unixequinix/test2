class AddProfileToTickets < ActiveRecord::Migration
  def change
    add_reference :tickets, :profile, index: true, foreign_key: true
    add_column :tickets, :active, :boolean, default: true

    sql = "UPDATE tickets GT
           SET profile_id = CA.profile_id, active = (CASE WHEN CA.aasm_state = 'assigned' THEN true ELSE false END)
           FROM credential_assignments CA
           WHERE  CA.credentiable_id = GT.id and CA.credentiable_type = 'Ticket';"

    ActiveRecord::Base.connection.execute(sql)
  end
end
