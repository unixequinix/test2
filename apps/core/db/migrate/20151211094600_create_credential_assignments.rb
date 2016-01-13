class CreateCredentialAssignments < ActiveRecord::Migration
  class Admission < ActiveRecord::Base
    belongs_to :customer_event_profile
    belongs_to :ticket
  end

  class GtagRegistration < ActiveRecord::Base
    belongs_to :customer_event_profile
    belongs_to :gtag
    has_one :event, through: :gtag
  end

  def change
    create_table :credential_assignments do |t|
      t.belongs_to :customer_event_profile, null: false
      t.references :credentiable, polymorphic: true, null: false
      t.string :aasm_state
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end

    move_records_to_credential_assignments("#{self.class.name}::Admission", "ticket")
    move_records_to_credential_assignments("#{self.class.name}::GtagRegistration", "gtag")

    if (CredentialAssignment.count == Admission.count + GtagRegistration.count)
      drop_table :admissions
      drop_table :gtag_registrations
    end
  end

  def move_records_to_credential_assignments(resource, extra_attribute)
    klass = resource.constantize
    list_credential_assignments = klass.includes(extra_attribute.to_sym).all.map do |item|
      CredentialAssignment.new(
        aasm_state: item[:aasm_state],
        customer_event_profile_id: item[:customer_event_profile_id],
        credentiable: item.send(extra_attribute.to_sym)
      )
    end
    CredentialAssignment.import(list_credential_assignments)
    puts "#{klass} Imported √"
  end
end
