# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  name                   :string           default(""), not null
#  surname                :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  agreed_on_registration :boolean          default(FALSE)
#  phone                  :string
#  postcode               :string
#  address                :string
#  city                   :string
#  country                :string
#  gender                 :string
#  birthdate              :datetime
#  event_id               :integer          not null
#  agreed_event_condition :boolean          default(FALSE)
#  remember_token         :string
#

class Customer < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order('email') }

  # Genders
  MALE = 'male'
  FEMALE = 'female'

  GENDERS = [MALE, FEMALE]

  # Associations
  has_one :customer_event_profile
  belongs_to :event

  # Validations
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :email, :name, :surname, :encrypted_password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }

  validates_uniqueness_of :email, scope: [:event_id], conditions: -> { where(deleted_at: nil) }

  # Hooks
  before_create :init_confirmation_token

  # Methods
  # -------------------------------------------------------

  def confirm!
    self.confirmation_token = nil
    self.confirmed_at = Time.now.utc
    save!
  end

  def update_tracked_fields!(request)
    self.last_sign_in_at = current_sign_in_at || Time.now.utc
    self.current_sign_in_at = Time.now.utc

    self.last_sign_in_ip = current_sign_in_ip || request.env['REMOTE_ADDR']
    self.current_sign_in_ip = request.env['REMOTE_ADDR']

    self.sign_in_count ||= 0
    self.sign_in_count += 1
    save!
  end

  def init_confirmation_token
    generate_token(:confirmation_token)
  end

  def init_password_token!
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.now.utc
    save
  end

  def init_remember_token!
    generate_token(:remember_token)
    self.remember_created_at = Time.now.utc
    save
  end

  def remember_me_token_expires_at(expiration_time)
    remember_created_at + expiration_time
  end

  def self.gender_selector
    GENDERS.map { |f| [I18n.t('gender.' + f), f] }
  end

  private

  def self.find_for_authentication(warden_conditions)
    where(email: warden_conditions[:email], event_id: warden_conditions[:event_id]).first
  end

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless Customer.exists?(column => self[column])
    end
  end
end
