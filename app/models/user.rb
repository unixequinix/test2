class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :validatable, :trackable, authentication_keys: [:login]

  has_many :event_registrations, dependent: :destroy
  has_many :events, through: :event_registrations, dependent: :destroy
  has_many :api_metrics, dependent: :nullify
  has_many :team_invitations, dependent: :destroy
  has_one :active_team_invitation, -> { where(active: true) }, class_name: 'TeamInvitation', inverse_of: :user
  has_one :team, through: :active_team_invitation, foreign_key: "team_id"

  before_create :generate_access_token

  has_attached_file(:avatar, styles: { thumb: '50x50#', medium: '200x200#', big: '500x500#' }, default_url: ':default_user_avatar_url')
  validates_attachment_content_type :avatar, content_type: %r{\Aimage/.*\Z}

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { within: Devise.password_length },
                       format: { with: /\A(?=.*\d)(?=.*[a-z])|(?=.*\d)(?=.*[a-z])\z/, message: 'must include 1 lowercase letter and 1 digit' },
                       unless: (-> { password.nil? })

  enum role: { glowball: 2, admin: 0, promoter: 1 }

  attr_accessor :login

  def team_role
    team_leader? ? 'leader' : 'guest'
  end

  def team_leader?
    active_team_invitation&.leader?
  end

  def devise_mailer
    UserMailer
  end

  def admin?
    super || glowball?
  end

  def registration_for(event)
    event_registrations.find_by(event: event)
  end

  def self.authenticate(username, password)
    user = User.find_for_database_authentication(login: username)
    user&.valid_password?(password) ? user : nil
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
end
