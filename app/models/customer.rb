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
#  locale                 :string           default("en")
#

class Customer < ActiveRecord::Base
  acts_as_paranoid
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable,
         authentication_keys: [:email, :event_id],
         reset_password_keys: [:email, :event_id], omniauth_providers: [:facebook, :google_oauth2]
  default_scope { order("email") }

  # Genders
  MALE = "male".freeze
  FEMALE = "female".freeze

  GENDERS = [MALE, FEMALE].freeze

  # Associations
  has_one :profile

  belongs_to :event

  # Validations
  validates :email, format: { with: RFC822::EMAIL }
  validates :email, :first_name, :encrypted_password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }

  validates :email, uniqueness: { scope: [:event_id], conditions: -> { where(deleted_at: nil) } }

  before_save do
    email.downcase! if email
  end

  scope :selected_data, lambda { |event|
    customers = select("id, first_name, last_name, email, birthdate, phone, postcode, address, city, country, gender")
                .where(event: event)
    customers.where(receive_communications: true) if event.receive_communications?
  }

  # Methods
  # -------------------------------------------------------

  def self.from_omniauth(auth, event)
    where(provider: auth.provider, uid: auth.uid, event: event).first_or_create do |user|
      token = Devise.friendly_token[0, 20]
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.first_name = auth.info.name
      user.password = token
      user.password_confirmation = token
      user.agreed_on_registration = true
    end
  end

  def self.gender_selector
    GENDERS.map { |f| [I18n.t("gender." + f), f] }
  end

  def autotopup_amounts(payment_gateway)
    amount = current_autotopup_amount(payment_gateway)
    (PaymentGatewayCustomer::AUTOTOPUP_AMOUNTS + [amount]).uniq.sort
  end

  def current_autotopup_amount(payment_gateway)
    payment_gateway.autotopup_amount
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  private

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless Customer.exists?(column => self[column])
    end
  end
end
