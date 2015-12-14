# == Schema Information
#
# Table name: credential_assignments
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  credentiable_id           :integer          not null
#  credentiable_type         :string           not null
#  aasm_state                :string
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class CredentialAssignment < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :customer_event_profile
  belongs_to :credentiable, polymorphic: true, touch: true

  # State machine
  include AASM
  aasm do
    state :unassigned, initial: true
    state :assigned

    event :assign do
      transitions from: :unassigned, to: :assigned
    end

    event :unassign do
      transitions from: :assigned, to: :unassigned
    end
  end
end
