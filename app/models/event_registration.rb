class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true

  validates :email, format: Devise.email_regexp

  enum role: { promoter: 1, support: 2, vendor: 3 }
end
