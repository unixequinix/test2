# == Schema Information
#
# Table name: rfid_tag_registrations
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  rfid_tag_id :integer          not null
#  aasm_state  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class RfidTagRegistration < ActiveRecord::Base

  # Associations
  belongs_to :customer
  belongs_to :rfid_tag

  # Validations
  validates :customer, :rfid_tag, :aasm_state, presence: true
  validates_uniqueness_of :rfid_tag, conditions: -> { where(aasm_state: :assigned) }

  # State machine
  include AASM

  aasm do
    state :assigned, initial: true
    state :unassigned

    event :unassign do
      transitions from: :assigned, to: :unassigned
    end
  end

end

end
