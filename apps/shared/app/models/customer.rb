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

class Customer < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order('email') }

  #Genders
  MALE = 'male'
  FEMALE = 'female'

  GENDERS = [MALE, FEMALE]

  # Constants
  MAIL_FORMAT = Devise.email_regexp
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable,
         authentication_keys: [:email, :event_id]

  # Associations
  has_many :customer_event_profiles
  belongs_to :event

  # Validations
  validates :email, format: { with: MAIL_FORMAT }, presence: true
  validates :name, :surname, :password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }

  validates_length_of :password, within: Devise.password_length, allow_blank: true
  validates_uniqueness_of :email, scope: [:event_id], conditions: -> { where(deleted_at: nil) }
  validate :validate_configurable_fields


  # Methods
  # -------------------------------------------------------


  def self.gender_selector
    GENDERS.map { |f| [I18n.t('gender.' + f), f] }
  end

  protected

  def self.find_for_authentication(warden_conditions)
    where(email: warden_conditions[:email],
          event_id: warden_conditions[:event_id]).first
  end

  private

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

  def validate_configurable_fields
  end

end
