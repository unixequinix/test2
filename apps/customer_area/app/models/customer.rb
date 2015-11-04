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
#
require 'bcrypt'

class Customer < ActiveRecord::Base
  include BCrypt
  acts_as_paranoid
  default_scope { order('email') }

  #Genders
  MALE = 'male'
  FEMALE = 'female'

  GENDERS = [MALE, FEMALE]

  # Associations
  has_one :customer_event_profile
  belongs_to :event

  # Validations
  #validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :email, presence: true
  validates :name, :surname, :password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }

  validates_uniqueness_of :email, scope: [:event_id], conditions: -> { where(deleted_at: nil) }

  # Hooks
  before_create :generate_confirmation_token

  # Methods
  # -------------------------------------------------------

  def password
    @password ||= Password.new(self.encrypted_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end

  def confirm!
    self.confirmation_token = nil
    self.confirmed_at = Time.now.utc
    self.save!
  end

  def init_password_token!
    generate_reset_password_token
    self.save
  end

  def self.gender_selector
    GENDERS.map { |f| [I18n.t('gender.' + f), f] }
  end

  private

  def self.find_for_authentication(warden_conditions)
    where(email: warden_conditions[:email],
          event_id: warden_conditions[:event_id]).first
  end

  def valid_birthday?
    birthdate_is_date? && enough_age?
  end

  def birthdate_is_date?
    unless(birthdate.is_a?(ActiveSupport::TimeWithZone))
      errors.add(
        :birthdate,
        I18n.t('activemodel.errors.models.customer.attributes.birthdate.invalid')
      )
      false
    else
      true
    end
  end

  def enough_age?
    minimum_age = 12
    unless(Date.today.midnight - minimum_age.years >= birthdate.midnight)
      errors.add(
        :birthdate,
        I18n.t('activemodel.errors.models.customer.attributes.birthdate.too_young',
          age: minimum_age
        )
      )
    end
  end

  def generate_confirmation_token
    loop do
      token = SecureRandom.urlsafe_base64
      unless Customer.where(confirmation_token: token).any?
        self.confirmation_token = token
        break
      end
    end
  end

  def generate_reset_password_token
    loop do
      token = SecureRandom.urlsafe_base64
      unless Customer.where(reset_password_token: token).any?
        self.reset_password_token = token
        self.reset_password_sent_at = Time.now.utc
        break
      end
    end
  end

end
