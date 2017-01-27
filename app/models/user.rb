# == Schema Information
#
# Table name: users
#
#  access_token           :string           not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :citext           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("support")
#  sign_in_count          :integer          default(0), not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_event_id              (event_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_c310acab8d  (event_id => events.id)
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :recoverable, :validatable

  belongs_to :event

  has_many :owned_events, foreign_key: :owner_id, class_name: "Event"

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :email, presence: true, uniqueness: true

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
