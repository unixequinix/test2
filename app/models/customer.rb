class Customer < ApplicationRecord # rubocop:disable Metrics/ClassLength
  devise :database_authenticatable, :registerable, :recoverable, :omniauthable, :trackable, :confirmable,
         authentication_keys: %i[email event_id],
         reset_password_keys: %i[email event_id],
         reset_password_within: 1.day,
         sign_in_after_reset_password: true,
         omniauth_providers: %i[facebook google_oauth2]

  belongs_to :event

  has_one(:active_gtag, -> { where(active: true) }, class_name: "Gtag")

  has_many :orders, dependent: :restrict_with_error
  has_many :refunds, dependent: :destroy

  # only two relationships allowed with anonymous customers
  has_many :tickets, dependent: :nullify
  has_many :gtags, dependent: :nullify
  has_many :transactions, dependent: :restrict_with_error

  validates :email, format: { with: RFC822::EMAIL }, allow_blank: true, if: :anonymous?
  validates :email, format: { with: RFC822::EMAIL }, allow_blank: false, unless: :anonymous?
  validates :email, uniqueness: { scope: [:event_id] }, allow_blank: true, if: :anonymous?
  validates :email, uniqueness: { scope: [:event_id] }, allow_blank: false, unless: :anonymous?
  validates :email, :first_name, :last_name, :encrypted_password, presence: true, unless: :anonymous?
  validates :agreed_on_registration, acceptance: { accept: true }, unless: :anonymous?
  validates :agreed_event_condition, acceptance: { accept: true }, if: (-> { event&.agreed_event_condition? }), unless: :anonymous?
  validates :phone, presence: true, if: (-> { custom_validation("phone") })
  validates :birthdate, presence: true, if: (-> { custom_validation("birthdate") })
  validates :phone, presence: true, if: (-> { custom_validation("phone") })
  validates :postcode, presence: true, if: (-> { custom_validation("address") })
  validates :address, presence: true, if: (-> { custom_validation("address") })
  validates :city, presence: true, if: (-> { custom_validation("address") })
  validates :country, presence: true, if: (-> { custom_validation("address") })
  validates :gender, presence: true, if: (-> { custom_validation("gender") })

  scope(:query_for_csv, lambda { |event|
    where(event: event)
      .joins("LEFT OUTER JOIN gtags ON gtags.customer_id = customers.id")
      .joins("LEFT OUTER JOIN tickets ON tickets.customer_id = customers.id")
      .select("customers.id, tickets.code as ticket, gtags.tag_uid as gtag, gtags.credits as credits,
               gtags.refundable_credits as refundable_credits, email, first_name, last_name")
      .group("customers.id, first_name, tickets.code, gtags.tag_uid, gtags.credits, gtags.refundable_credits")
      .order("first_name ASC")
  })

  def self.claim(event, customer_id, anon_customer_id)
    return false if anon_customer_id.blank? || customer_id.blank?
    return true if customer_id == anon_customer_id

    anon_customer = event.customers.find(anon_customer_id)

    message = "PROFILE FRAUD: customer #{anon_customer_id} is not anonymous when trying to claim"
    Alert.propagate(event, event.customers.find(customer_id), message) && return unless anon_customer.anonymous?

    anon_customer.transactions.update_all(customer_id: customer_id)
    anon_customer.gtags.update_all(customer_id: customer_id)
    anon_customer.tickets.update_all(customer_id: customer_id)
    anon_customer.destroy!
  end

  def valid_balance?
    positive = !global_credits.negative? && !global_refundable_credits.negative?
    (active_gtag.blank? && positive) || (active_gtag&.valid_balance? && positive)
  end

  def name
    anonymous? ? "Anonymous customer" : "#{first_name} #{last_name}"
  end

  def full_email
    anonymous? ? "Anonymous email" : email
  end

  def global_credits
    # TODO: This method will need to take into account refunds when we stop creating negative online orders
    transactions_balance = event.transactions.credit.onsite.status_ok.where(gtag: gtags, action: "record_credit").sum(:credits)
    redeemed_credits = gtags.any? ? transactions_balance : 0.00
    active_gtag&.credits.to_f + orders.where(status: %w[completed refunded]).map(&:credits).sum - redeemed_credits
  end

  def global_refundable_credits
    # TODO: This method will need to take into account refunds when we stop creating negative online orders
    transactions_balance = event.transactions.credit.onsite.status_ok.where(gtag: gtags, action: "record_credit").sum(:refundable_credits)
    redeemed_credits = gtags.any? ? transactions_balance : 0.00
    active_gtag&.refundable_credits.to_f + orders.where(status: %w[completed refunded]).map(&:refundable_credits).sum - redeemed_credits
  end

  def global_money
    global_credits * event.credit.value
  end

  def global_refundable_money
    global_refundable_credits * event.credit.value
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
    atts[:event] = event
    order = orders.new(atts)
    last_counter = order_items.pluck(:counter).sort.last.to_i
    items.each.with_index do |arr, index|
      arr.unshift(event.credit.id) if arr.size.eql?(1)
      item_id, amount = arr
      amount = amount.to_f
      next if amount.zero?

      item = event.catalog_items.find(item_id)
      counter = last_counter + index + 1
      total = amount * item.price.to_f
      order.order_items.new(catalog_item: item, amount: amount, total: total, counter: counter)
    end
    order
  end

  def can_purchase_item?(catalog_item)
    active_credentials.map { |credential| credential.ticket_type&.catalog_item }.compact.include?(catalog_item)
  end

  def infinite_accesses_purchased
    catalog_items = order_items.pluck(:catalog_item_id)
    accesses = Access.where(id: catalog_items).infinite.pluck(:id)
    packs = Pack.joins(:catalog_items)
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

  def email_required?
    false
  end

  def email_changed?
    false
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
