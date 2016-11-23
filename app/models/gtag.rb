# == Schema Information
#
# Table name: gtags
#
#  activation_counter       :integer          default(1)
#  active                   :boolean          default(TRUE)
#  banned                   :boolean          default(FALSE)
#  created_at               :datetime         not null
#  credits                  :decimal(8, 2)
#  final_balance            :decimal(8, 2)
#  final_refundable_balance :decimal(8, 2)
#  format                   :string           default("wristband")
#  loyalty                  :boolean          default(FALSE)
#  refundable_credits       :decimal(8, 2)
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_gtags_on_customer_id  (customer_id)
#  index_gtags_on_event_id     (event_id)
#
# Foreign Keys
#
#  fk_rails_084fd46c5e  (event_id => events.id)
#  fk_rails_70b4405c01  (customer_id => customers.id)
#

class Gtag < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  STANDARD = "standard".freeze
  CARD = "card".freeze
  SIMPLE = "simple".freeze
  WRISTBAND = "wristband".freeze

  # UID categorization of the gtags
  UID_FORMATS = [STANDARD, CARD, SIMPLE].freeze

  # Physical type of the gtags
  FORMATS = [CARD, WRISTBAND].freeze

  # Gtag limits
  DEFINITIONS = { mifare_classic: { entitlement_limit: 15, credential_limit: 15 },
                  ultralight_ev1: { entitlement_limit: 40, credential_limit: 32 },
                  ultralight_c:   { entitlement_limit: 56, credential_limit: 32 } }.freeze

  SETTINGS = [:format, :gtag_type, :maximum_gtag_balance, :cards_can_refund, :gtag_deposit,
              :wristbands_can_refund].freeze

  belongs_to :event
  belongs_to :customer

  has_many :transactions

  before_validation :upcase_gtag!

  validates :tag_uid, uniqueness: { scope: [:event_id, :activation_counter] }
  validates :tag_uid, presence: true

  scope :query_for_csv, ->(event) { event.gtags.select("id, tag_uid, banned, loyalty, format") }
  scope :banned, -> { where(banned: true) }
  default_scope { order(:id) }

  alias_attribute :reference, :tag_uid

  def self.chips
    DEFINITIONS.keys.map { |f| [I18n.t("admin.gtag_settings.form." + f.to_s), f] }
  end

  def recalculate_balance
    ts = transactions.credit.status_ok.order(gtag_counter: :asc)

    self.credits = ts.map(&:credits).sum
    self.refundable_credits = ts.map(&:refundable_credits).sum
    self.final_balance = ts.last&.final_balance.to_f
    self.final_refundable_balance = ts.last&.final_refundable_balance.to_f

    save
  end

  def refundable_money
    refundable_credits.to_i * event.credit.value
  end

  def valid_balance?
    credits == final_balance && refundable_credits == final_refundable_balance
  end

  def assigned?
    customer.present?
  end

  # Defines a method with a question mark for each gtag format which returns if the gtag has that format
  FORMATS.each do |method_name|
    define_method "#{method_name}?" do
      format == method_name
    end
  end

  def upcase_gtag!
    tag_uid.upcase! if tag_uid
  end

  def can_refund?
    card_can_refund = card? && event.gtag_settings["cards_can_refund"] == "true"
    wristband = wristband? && event.gtag_settings["wristbands_can_refund"] == "true"
    return true if loyalty? || card_can_refund || wristband
  end

  def self.counters(event) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT to_json(json_agg(row_to_json(cust)))
      FROM (
        SELECT
          customer_trans.gtag_id,
          MAX(customer_trans.gtag_counter) as gtag,
          SUM(customer_trans.gtag_counter) as gtag_total,
          MAX(customer_trans.gtag_counter) * (MAX(customer_trans.gtag_counter) + 1) / 2 as gtag_last_total,
          MAX(customer_trans.counter) as online,
          SUM(customer_trans.counter) as online_total,
          MAX(customer_trans.counter) * (MAX(customer_trans.counter) + 1) / 2 as online_last_total
        FROM (
          SELECT gtag_id, gtag_counter, counter
          FROM transactions
          WHERE event_id = #{event.id} AND status_code = 0
        ) customer_trans
        GROUP BY customer_trans.gtag_id
        ORDER BY customer_trans.gtag_id
      ) cust
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    JSON.parse(sql).to_a.group_by { |t| t["gtag_id"] }
  end

  def self.credits_sum(event) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT to_json(json_agg(row_to_json(inc)))
      FROM (
        SELECT
          id,
          credits,
          refundable_credits,
          final_balance,
          final_refundable_balance,
          final_balance - credits as inconsistent,
          final_refundable_balance - refundable_credits as inconsistent_refundable
        FROM gtags
        WHERE event_id = #{event.id} AND
              (final_balance <> credits OR final_refundable_balance <> refundable_credits)
        ORDER BY inconsistent DESC
      ) inc
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    JSON.parse(sql).to_a
  end
end
