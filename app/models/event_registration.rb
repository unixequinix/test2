class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :email, format: Devise.email_regexp

  scope :unanswered, (-> { where(accepted: nil) })
  scope :answered, (-> { where(accepted: true) })

  enum role: { promoter: 1, support: 2, vendor: 3 }
end
