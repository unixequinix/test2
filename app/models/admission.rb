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
  puts '+++++ Hey, I am in Admission'


  # Associations
  belongs_to :customer_event_profile
  belongs_to :ticket

  # Validations
  validates :customer_event_profile, :ticket, :aasm_state, presence: true
  validates_uniqueness_of :ticket,
    conditions: -> { where(aasm_state: :assigned) }
  validate :ticket_belongs_to_current_event

  # State machine
  include AASM

  aasm do
    state :assigned, initial: true
    state :unassigned

    event :unassign do
      transitions from: :assigned, to: :unassigned
    end
  end

  private

  def ticket_belongs_to_current_event
    errors.add(:ticket_id, I18n.t("errors.messages.not_belong_to_event")) unless self.ticket.event == self.customer_event_profile.event
  end
end
