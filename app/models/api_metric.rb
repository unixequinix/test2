class ApiMetric < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  scope :tickets_create, -> { where(controller: "tickets", action: "create") }
  scope :topup, -> { where(action: "topup") }
end
