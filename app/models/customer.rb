class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :omniauthable, :trackable, :confirmable,
         authentication_keys: %i[email event_id],
         reset_password_keys: %i[email event_id],
         reset_password_within: 1.day,
         sign_in_after_reset_password: true,
         omniauth_providers: %i[facebook google_oauth2]

  belongs_to :event, counter_cache: true

  has_one :active_gtag, -> { where(active: true) }, class_name: "Gtag", inverse_of: :customer

  has_many :orders, dependent: :restrict_with_error
  has_many :refunds, dependent: :restrict_with_error
  has_many :tickets, dependent: :nullify
  has_many :gtags, dependent: :nullify
  has_many :transactions, dependent: :restrict_with_error
  has_many :transactions_as_operator, class_name: "Transaction", foreign_key: "operator_id", dependent: :restrict_with_error, inverse_of: :operator
  has_many :pokes, dependent: :restrict_with_error
  has_many :pokes_as_operator, class_name: "Poke", foreign_key: "operator_id", dependent: :restrict_with_error, inverse_of: :operator

  has_attached_file(:avatar, styles: { thumb: '50x50#', medium: '200x200#', big: '500x500#' }, default_url: ':default_user_avatar_url')
  validates_attachment_content_type :avatar, content_type: %r{\Aimage/.*\Z}

  with_options unless: :anonymous? do |reg|
    reg.validates :email, format: { with: RFC822::EMAIL }, allow_blank: false
    reg.validates :email, uniqueness: { scope: [:event_id] }, allow_blank: false
    reg.validates :email, :first_name, :last_name, :encrypted_password, presence: true
    reg.validates :agreed_on_registration, acceptance: { accept: true }
    reg.validates :agreed_event_condition, acceptance: { accept: true }, if: (-> { event&.agreed_event_condition? })

    reg.validates :password, presence: true,
                             confirmation: true,
                             length: { within: Devise.password_length },
                             format: { with: /\A(?=.*\d)(?=.*[a-z])|(?=.*\d)(?=.*[a-z])\z/, message: 'must include 1 lowercase letter and 1 digit' },
                             unless: (-> { password.nil? })
  end

  validates :phone, presence: true, if: (-> { custom_validation("phone") })
  validates :birthdate, presence: true, if: (-> { custom_validation("birthdate") })
  validates :phone, presence: true, if: (-> { custom_validation("phone") })
  validates :postcode, presence: true, if: (-> { custom_validation("address") })
  validates :address, presence: true, if: (-> { custom_validation("address") })
  validates :city, presence: true, if: (-> { custom_validation("address") })
  validates :country, presence: true, if: (-> { custom_validation("address") })
  validates :gender, presence: true, if: (-> { custom_validation("gender") })

  scope(:query_for_csv, lambda { |event|
    where(event: event).joins(:gtags, :tickets).order(:first_name)
      .select("customers.id, tickets.code as ticket, gtags.tag_uid as gtag, gtags.credits, gtags.virtual_credits, email, first_name, last_name")
      .group("customers.id, first_name, tickets.code, gtags.tag_uid, gtags.credits, gtags.virtual_credits")
  })

  def self.claim(event, customer, anon_customers)
    anon_customers = [anon_customers].flatten.compact

    return customer if customer.blank? || anon_customers.map(&:id).uniq.all? { |id| id == customer.id }

    message = "PROFILE FRAUD: customers #{anon_customers.map(&:id).to_sentence} are registered when trying to claim"
    Alert.propagate(event, customer, message) && return if anon_customers.map(&:registered?).any?

    anon_customers.each do |anon_customer|
      anon_customer.transactions.update_all(customer_id: customer.id)
      anon_customer.pokes.update_all(customer_id: customer.id)
      anon_customer.gtags.update_all(customer_id: customer.id)
      anon_customer.tickets.update_all(customer_id: customer.id)
      anon_customer.destroy!
    end

    customer
  end

  def valid_balance?
    positive = (credits && virtual_credits) >= 0
    active_gtag.present? ? (active_gtag.valid_balance? && positive) : positive
  end

  def registered?
    !anonymous?
  end

  def name
    result = "#{first_name} #{last_name}"
    result = "Anonymous customer" if anonymous?
    result = "Anonymous operator" if anonymous? && operator?
    result
  end

  def full_email
    anonymous? ? "Anonymous email" : email
  end

  def credits
    order_total = orders.completed.includes(:order_items).reject(&:redeemed?).sum(&:credits)
    refund_total = refunds.completed.sum(&:credit_total)
    order_total - refund_total + active_gtag&.credits.to_f
  end

  def virtual_credits
    order_total = orders.completed.includes(:order_items).reject(&:redeemed?).sum(&:virtual_credits)
    order_total + active_gtag&.virtual_credits.to_f
  end

  def money
    credits * event.credit.value
  end

  def virtual_money
    virtual_credits * event.credit.value
  end

  def credentials
    gtags + tickets
  end

  def active_credentials
    [active_gtag, tickets.where(banned: false)].flatten.compact
  end

  def order_items
    OrderItem.where(order: orders)
  end

  def build_order(items, atts = {})
    order = orders.new(atts.merge(event: event, status: "in_progress"))

    items.each do |arr|
      arr.unshift(event.credit.id) if arr.size.eql?(1)
      item_id, amount = arr
      order.order_items.new(catalog_item: event.catalog_items.find(item_id), amount: amount.to_f) unless amount.to_f.zero?
    end
    order.set_counters
  end

  def can_purchase_item?(catalog_item)
    active_credentials.map { |credential| credential.ticket_type&.catalog_item }.compact.include?(catalog_item)
  end

  def infinite_accesses_purchased
    catalog_items = order_items.pluck(:catalog_item_id)
    accesses = event.accesses.where(id: catalog_items).infinite.pluck(:id)
    packs = event.packs.joins(:catalog_items)
                 .where(id: catalog_items, catalog_items: { type: "Access" })
                 .select { |pack| pack.catalog_items.accesses.infinite.any? }.map(&:id)

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
    customer.anonymous = false
    customer.skip_confirmation!
    customer.save
    customer
  end

  def custom_validation(field)
    event && event.method("#{field}_mandatory?").call && !reset_password_token_changed? &&
      (!encrypted_password_changed? || new_record?) && !anonymous?
  end

  private

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless Customer.exists?(column => self[column])
    end
  end
end
