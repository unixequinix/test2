class MoveAdmissionDataToAdmittances < ActiveRecord::Migration
  class Admission < ActiveRecord::Base
    belongs_to :customer
    belongs_to :ticket
    has_many :admittances
  end

  def change
    Admission.find_each do |admission|
      admission.admittances.create(
        ticket: admission.ticket,
        aasm_state: admission.aasm_state)
    end
  end
end
