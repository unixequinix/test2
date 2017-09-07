class Alert < ApplicationRecord
  belongs_to :event
  belongs_to :subject, polymorphic: true

  validates :body, presence: true

  scope :unresolved, (-> { where(resolved: false) })

  enum priority: { low: 0, medium: 1, high: 2 }

  def self.propagate(event, subject, body, priority = :high)
    event.alerts.find_or_create_by(body: body, priority: priority, subject: subject)
  end
end
