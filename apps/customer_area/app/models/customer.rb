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
#  remember_token         :string
#

class Customer < ActiveRecord::Base
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
    old_current, new_current = self.current_sign_in_at, Time.now.utc
    self.last_sign_in_at     = old_current || new_current
    self.current_sign_in_at  = new_current

    old_current, new_current = self.current_sign_in_ip, request.env["REMOTE_ADDR"]
    self.last_sign_in_ip     = old_current || new_current
    self.current_sign_in_ip  = new_current

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

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Customer.exists?(column => self[column])
  end

end
