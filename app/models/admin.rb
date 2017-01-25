# == Schema Information
#
# Table name: admins
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
#  role                   :integer          default(3)
#  sign_in_count          :integer          default(0), not null
#
# Indexes
#
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_event_id              (event_id)
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_c310acab8d  (event_id => events.id)
#

class Admin < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :recoverable, :validatable

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :email, presence: true, uniqueness: true

  before_create :generate_access_token

  def valid_token?(token)
    access_token == token
  end

  def customer_service?
    email.start_with?("support_")
  end

  def promoter?
    email.start_with?("admin_")
  end

  def root?
    !(promoter? || customer_service?)
  end

  def slug
    result = email[/[^@]+/]
    result.gsub! "admin_", ""
    result.gsub! "support_", ""
    result
  end

  private

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless self.class.exists?(access_token: access_token)
    end
  end
end
