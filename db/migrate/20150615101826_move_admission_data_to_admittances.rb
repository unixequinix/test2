class MoveAdmissionDataToAdmittances < ActiveRecord::Migration
  def change
    Admission.find_each do |admission|
      admission.admittances.create(
        ticket: admission.ticket,
        aasm_state: admission.aasm_state)
    end
  end
end
