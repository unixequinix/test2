# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  event_id               :integer          not null
#  email                  :string           default(""), not null
#  first_name             :string           default(""), not null
#  last_name              :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  phone                  :string
#  postcode               :string
#  address                :string
#  city                   :string
#  country                :string
#  gender                 :string
#  remember_token         :string
#  sign_in_count          :integer          default(0), not null
#  agreed_on_registration :boolean          default(FALSE)
#  agreed_event_condition :boolean          default(FALSE)
#  last_sign_in_ip        :inet
#  current_sign_in_ip     :inet
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  birthdate              :datetime
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Customer < ActiveRecord::Base
  include Trackable
  acts_as_paranoid
  default_scope { order("email") }

  # Genders
  MALE = "male"
  FEMALE = "female"

  GENDERS = [MALE, FEMALE]

  # Associations
  has_one :profile

  belongs_to :event

  # Validations
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :email, :first_name, :last_name, :encrypted_password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }

  validates_uniqueness_of :email, scope: [:event_id], conditions: -> { where(deleted_at: nil) }

  # Methods
  # -------------------------------------------------------

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
    GENDERS.map { |f| [I18n.t("gender." + f), f] }
  end

  def self.find_for_authentication(warden_conditions)
    where(email: warden_conditions[:email], event_id: warden_conditions[:event_id]).first
  end

  private

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless Customer.exists?(column => self[column])
    end
  end
end
