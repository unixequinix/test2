# == Schema Information
#
# Table name: gtag_registrations
#
#  id                        :integer          not null, primary key
#  gtag_id                   :integer          not null
#  aasm_state                :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_event_profile_id :integer          not null
#

class GtagAssignment < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :customer_event_profile
  belongs_to :gtag
  has_one :event, through: :gtag

  # Validations
  validates :customer_event_profile, :gtag, :aasm_state, presence: true
  validates_uniqueness_of :gtag, conditions: -> { where(aasm_state: :assigned) }
  validate :gtag_belongs_to_current_event

  # State machine
  include AASM

  aasm do
    state :assigned, initial: true
    state :unassigned

    event :unassign do
      transitions from: :assigned, to: :unassigned
    end
  end

  def customer_event_profile
    CustomerEventProfile.unscoped { super }
  end

  private

  def gtag_belongs_to_current_event
    errors.add(:gtag_id, I18n.t("errors.messages.not_belong_to_event")) unless gtag.event == customer_event_profile.event
  end
end
