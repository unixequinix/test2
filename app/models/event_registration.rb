class EventRegistration < ApplicationRecord
  belongs_to :event, counter_cache: true
  belongs_to :user, optional: true

  validates :email, format: Devise.email_regexp
  validates :user_id, uniqueness: { scope: :event_id }, allow_nil: true

  enum role: { promoter: 1, support: 2, device_register: 3 }
end
