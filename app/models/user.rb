class User < ApplicationRecord
  devise :database_authenticatable, :validatable, :trackable

  has_many :event_registrations, (-> { answered })
  has_many :events, through: :event_registrations

  before_create :generate_access_token

  validates :username, presence: true, uniqueness: true

  enum role: { admin: 0, promoter: 1 }

  def registration_for(event)
    event_registrations.unscoped.find_by(event: event, user: self)
  end

  private

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless User.exists?(access_token: access_token)
    end
  end
end
