# == Schema Information
#
# Table name: gtag_registrations
#
#  id           :integer          not null, primary key
#  gtag_id      :integer          not null
#  aasm_state   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  admission_id :integer          default(1), not null
#

class GtagRegistration < ActiveRecord::Base
  # Associations
  belongs_to :admission
  belongs_to :gtag

  # Validations
  validates :admission, :gtag, :aasm_state, presence: true
  validates_uniqueness_of :gtag, conditions: -> { where(aasm_state: :assigned) }

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
