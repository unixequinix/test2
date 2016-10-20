class Customer < ActiveRecord::Base
  acts_as_paranoid
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable,
         authentication_keys: [:email, :event_id], reset_password_keys: [:email, :event_id],
         omniauth_providers: [:facebook, :google_oauth2]
  default_scope { order("email") }

  # Constants
  MALE = "male".freeze
  FEMALE = "female".freeze
  GENDERS = [MALE, FEMALE].freeze

  # Associations
  has_one :profile
  belongs_to :event

  # Validations
  validates :email, format: { with: RFC822::EMAIL }
  validates :email, uniqueness: { scope: [:event_id], conditions: -> { where(deleted_at: nil) } }
  validates :email, :first_name, :last_name, :encrypted_password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }
  validates :agreed_event_condition, acceptance: { accept: true }, if: -> { event && event.agreed_event_condition? }
  validates :phone, presence: true, if: -> { event && event.phone? }
  validates :birthdate, presence: true, if: -> { event && event.birthdate? }
  validates :phone, presence: true, if: -> { event && event.phone? }
  validates :postcode, presence: true, if: -> { event && event.postcode? }
  validates :address, presence: true, if: -> { event && event.address? }
  validates :city, presence: true, if: -> { event && event.city? }
  validates :country, presence: true, if: -> { event && event.country? }
  validates :gender, presence: true, if: -> { event && event.gender? }

  before_save do
    email.downcase! if email
  end

  scope :query_for_csv, lambda { |event|
    customers = event.customers.select("id, first_name, last_name, email, birthdate, phone, postcode, address, city,
                                       country, gender, created_at")
    event.receive_communications? ? customers.where(receive_communications: true) : customers
  }

  # Methods
  # -------------------------------------------------------

  def self.from_omniauth(auth, event)
    token = Devise.friendly_token[0, 20]
    first_name = auth.info&.first_name || auth.info.name.split(" ").first
    last_name = auth.info&.last_name || auth.info.name.split(" ").second

    customer = find_by(provider: auth.provider, uid: auth.uid, event: event)
    customer ||= event.customers.new(provider: auth.provider,
                                     uid: auth.uid,
                                     email: auth.info.email,
                                     first_name: first_name,
                                     last_name: last_name,
                                     password: token,
                                     password_confirmation: token,
                                     agreed_on_registration: true)

    customer.save unless event.receive_communications?
    customer
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
