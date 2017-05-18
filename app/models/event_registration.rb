class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :email, format: Devise.email_regexp

  scope :not_accepted, (-> { where(accepted: [nil, false]) })
  scope :accepted, (-> { where(accepted: true) })

  enum role: { promoter: 1, support: 2, vendor: 3 }
end
