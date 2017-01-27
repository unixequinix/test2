# == Schema Information
#
# Table name: customers
#
#  address                    :string
#  agreed_event_condition     :boolean          default(FALSE)
#  agreed_on_registration     :boolean          default(FALSE)
#  banned                     :boolean
#  birthdate                  :datetime
#  city                       :string
#  country                    :string
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  email                      :citext           default(""), not null
#  encrypted_password         :string           default(""), not null
#  first_name                 :string           default(""), not null
#  gender                     :string
#  last_name                  :string           default(""), not null
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  locale                     :string           default("en")
#  phone                      :string
#  postcode                   :string
#  receive_communications     :boolean          default(FALSE)
#  receive_communications_two :boolean          default(FALSE)
#  remember_token             :string
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  sign_in_count              :integer          default(0), not null
#
# Indexes
#
#  index_customers_on_event_id              (event_id)
#  index_customers_on_remember_token        (remember_token) UNIQUE
#  index_customers_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_0b9257e0c6  (event_id => events.id)
#

class Customer < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable,
         authentication_keys: [:email, :event_id], reset_password_keys: [:email, :event_id],
         omniauth_providers: [:facebook, :google_oauth2]

  belongs_to :event

  has_one :active_gtag, -> { where(active: true) }, class_name: "Gtag"

  has_many :orders, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :gtags, dependent: :nullify
  has_many :tickets, dependent: :nullify
  has_many :transactions, dependent: :restrict_with_error

  validates :email, format: { with: RFC822::EMAIL }
  validates :email, uniqueness: { scope: [:event_id] }
  validates :email, :first_name, :last_name, :encrypted_password, presence: true
  validates :agreed_on_registration, acceptance: { accept: true }
  validates :agreed_event_condition, acceptance: { accept: true }, if: -> { event&.agreed_event_condition? }
  validates :phone, presence: true, if: -> { custom_validation("phone") }
  validates :birthdate, presence: true, if: -> { custom_validation("birthdate") }
  validates :phone, presence: true, if: -> { custom_validation("phone") }
  validates :postcode, presence: true, if: -> { custom_validation("postcode") }
  validates :address, presence: true, if: -> { custom_validation("address") }
  validates :city, presence: true, if: -> { custom_validation("city") }
  validates :country, presence: true, if: -> { custom_validation("country") }
  validates :gender, presence: true, if: -> { custom_validation("gender") }

  scope :query_for_csv, lambda { |event|
    where(event: event)
      .joins("LEFT OUTER JOIN gtags ON gtags.customer_id = customers.id")
      .joins("LEFT OUTER JOIN tickets ON tickets.customer_id = customers.id")
      .select("customers.id, tickets.code as ticket, gtags.tag_uid as gtag, gtags.credits as credits, gtags.refundable_credits as refundable_credits, email, first_name, last_name") # rubocop:disable Metrics/LineLength
      .group("customers.id, first_name, tickets.code, gtags.tag_uid, gtags.credits, gtags.refundable_credits")
      .order("first_name ASC")
  }

  delegate :valid_balance?, to: :active_gtag

  def refunding?
    refunds.any? { |r| r.status.eql?("in_progress") || r.status.eql?("started") }
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def credits
    active_gtag&.credits.to_f - refunds.map(&:total).sum
  end

  def refundable_credits
    active_gtag&.refundable_credits.to_f - refunds.map(&:total).sum
  end

  def refundable_money
    (active_gtag&.refundable_credits.to_f * event.credit.value) - refunds.map(&:money).sum
  end

  def credentials
    gtags + tickets
  end

  def active_credentials
    [active_gtag, tickets].flatten.compact
  end

  def active_credentials?
    active_credentials.any?
  end

  def order_counters
    order_items.pluck(:counter).sort
  end

  def order_items
    OrderItem.where(order: orders)
  end

  def infinite_accesses_purchased
    catalog_items = order_items.pluck(:catalog_item_id)
    accesses = Access.where(id: catalog_items).infinite.pluck(:id)
    packs = Pack.joins(:catalog_items).where(id: catalog_items, catalog_items: { type: "Access" }).select { |pack| pack.catalog_items.accesses.infinite.any? }.map(&:id) # rubocop:disable Metrics/LineLength

    accesses + packs
  end

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

    customer.save unless event.receive_communications? || event.receive_communications_two?
    customer
  end

  def self.gender_selector
    %w(male female).map { |f| [I18n.t("gender." + f), f] }
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def custom_validation(field)
    event && event.method("#{field}_mandatory?").call && !reset_password_token_changed? &&
      (!encrypted_password_changed? || new_record?)
  end

  private

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless Customer.exists?(column => self[column])
    end
  end
end
