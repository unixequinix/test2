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
#  receive_communications :boolean          default(FALSE)
#

class Customer < ActiveRecord::Base
  include Trackable
  acts_as_paranoid
  default_scope { order("email") }

  # Genders
  MALE = "male".freeze
  FEMALE = "female".freeze

  GENDERS = [MALE, FEMALE].freeze

  # Associations
  has_one :profile

  belongs_to :event

  # Validations
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :email, :first_name, :last_name, :encrypted_password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }

  validates_uniqueness_of :email, scope: [:event_id], conditions: -> { where(deleted_at: nil) }

  before_save do
    email.downcase! if email
  end

  scope :selected_data, lambda { |event|
    customers = select("id, first_name, last_name, email, birthdate, phone, postcode, address, city, country, gender")
                .where(event: event)
    customers = customers.where(receive_communications: true) if event.receive_communications?
  }

  # Methods
  # -------------------------------------------------------
  def refund_status
    return "no_credentials_assigned" unless profile
    if profile.refundable_money_amount.zero? || !BalanceCalculator.new(profile).valid_balance?
      "not_eligible"
    elsif profile.completed_claim
      "completed"
    else
      "not_performed"
    end
  end

  def init_password_token!
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.zone.now.utc
    save
  end

  def init_remember_token!
    generate_token(:remember_token)
    self.remember_created_at = Time.zone.now.utc
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

  def autotopup_amounts(payment_gateway)
    amount = current_autotopup_amount(payment_gateway)
    (PaymentGatewayCustomer::AUTOTOPUP_AMOUNTS + [amount]).uniq.sort
  end

  def current_autotopup_amount(payment_gateway)
    payment_gateway.autotopup_amount
  end

  private

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless Customer.exists?(column => self[column])
    end
  end
end
