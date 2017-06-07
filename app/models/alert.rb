class Alert < ApplicationRecord
  belongs_to :event
  belongs_to :user
  belongs_to :subject, polymorphic: true

  validates :body, :event_id, :user_id, presence: true

  scope :unresolved, (-> { where(resolved: false) })

  enum priority: { low: 0, medium: 1, high: 2 }

  def self.propagate(event, body, priority, subject)
    ids_of_users = event.event_registrations.where(role: :promoter).pluck(:user_id)
    ids_of_users.map { |id_of_user| create!(event: event, body: body, priority: priority, subject: subject, user_id: id_of_user) }
  end
end
