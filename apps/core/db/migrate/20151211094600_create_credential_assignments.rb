class CreateCredentialAssignments
  def change
    create_table :orders do |t|
      t.belongs_to :credentiable_id, null: false
      t.belongs_to :customer_event_profile_id, null: false
      t.string :credentiable_type, null: false
      t.string :state

      t.timestamps null: false
    end
  end
do
