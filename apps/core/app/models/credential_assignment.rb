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

  # Validations
  validates :customer_event_profile, :credentiable, :aasm_state, presence: true
  # validate :credentiable_belongs_to_current_event
  validates :credentiable_id, uniqueness: { scope: :credentiable_type, conditions: -> { where(aasm_state: :assigned) } }

  # State machine
  include AASM
  aasm do
    state :assigned, initial: true
    state :unassigned

    event :assign do
      transitions from: :unassigned, to: :assigned
    end

    event :unassign do
      transitions from: :assigned, to: :unassigned
    end
  end

  def customer_event_profile
    CustomerEventProfile.unscoped { super }
  end

  private

  def credentiable_belongs_to_current_event
    errors.add(credentiable_type, I18n.t('errors.messages.not_belong_to_event')) unless credentiable.event == customer_event_profile.event
  end
end
