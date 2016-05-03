# == Schema Information
#
# Table name: credential_assignments
#
#  id                        :integer          not null, primary key
#  profile_id :integer
#  credentiable_id           :integer          not null
#  credentiable_type         :string           not null
#  aasm_state                :string
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class CredentialAssignment < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :profile
  belongs_to :credentiable, polymorphic: true, touch: true
  has_and_belongs_to_many :customer_orders, join_table: :c_assignments_c_orders

  # Validations
  validates :profile, :credentiable, :aasm_state, presence: true
  validates :credentiable_id, uniqueness: { scope: :credentiable_type,
                                            conditions: -> { where(aasm_state: :assigned) } }
  # validate :credentiable_belongs_to_current_event

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

  def profile
    Profile.unscoped { super }
  end

  private

  def credentiable_belongs_to_current_event
    same_event = credentiable.event == profile.event
    errors.add(credentiable_type, I18n.t("errors.messages.not_belong_to_event")) unless same_event
  end
end
