class EventInvitation < ApplicationRecord
  belongs_to :event

  validates :email, uniqueness: { scope: %i[event_id] }, format: Devise.email_regexp, presence: true
  validates :event_id, presence: true

  enum role: EventRegistration.roles

  scope :pendings, -> { where(accepted: false) }

  def accept!(user_id)
    return false unless user_id

    EventRegistration.create!(user_id: user_id, event_id: event_id, role: role)
    update!(accepted: true)
  end
end
