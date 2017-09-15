class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :validatable, :trackable, authentication_keys: [:login]

  has_many :event_registrations, dependent: :destroy
  has_many :events, through: :event_registrations, dependent: :destroy

  before_create :generate_access_token

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_username

  enum role: { admin: 0, promoter: 1 }

  attr_accessor :login

  def devise_mailer
    UserMailer
  end

  def registration_for(event)
    event_registrations.find_by(event: event)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      where(conditions.to_h).find_by(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }])
    elsif conditions.key?(:username) || conditions.key?(:email)
      find_by(conditions.to_h)
    end
  end

  private

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless User.exists?(access_token: access_token)
    end
  end

  def validate_username
    errors.add(:username, :invalid) if User.where(email: username).exists?
  end
end
