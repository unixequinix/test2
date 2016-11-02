class AddProfileToGtags < ActiveRecord::Migration
  def change
    add_reference :gtags, :profile, index: true, foreign_key: true
    add_column :gtags, :active, :boolean, default: true

    sql = "UPDATE gtags GT
           SET profile_id = CA.profile_id, active = (CASE WHEN CA.aasm_state = 'assigned' THEN true ELSE false END)
           FROM credential_assignments CA
           WHERE  CA.credentiable_id = GT.id and CA.credentiable_type = 'Gtag';"

    ActiveRecord::Base.connection.execute(sql)
  end
end
