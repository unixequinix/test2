# == Schema Information
#
# Table name: admissions
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer
#  ticket_id                 :integer
#  deleted_at                :datetime
#  aasm_state                :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Admission < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  belongs_to :customer_event_profile
  belongs_to :ticket

  # Validations
  validates :customer_event_profile, :ticket, :aasm_state, presence: true
  validates_uniqueness_of :ticket,
    conditions: -> { where(aasm_state: :assigned) }

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
