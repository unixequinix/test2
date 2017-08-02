class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true

  validates :email, format: Devise.email_regexp
  validates :user_id, uniqueness: { scope: :event_id }

  enum role: { promoter: 1, support: 2 }
end
