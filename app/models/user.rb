class User < ActiveRecord::Base
  devise :database_authenticatable, :validatable, :trackable

  belongs_to :event

  has_many :owned_events, foreign_key: :owner_id, class_name: "Event"

  before_create :generate_access_token

  enum role: { admin: 0, promoter: 1, support: 3 }

  private

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless User.exists?(access_token: access_token)
    end
  end
end
