# == Schema Information
#
# Table name: credit_transactions
#
#  id                       :integer          not null, primary key
#  event_id                 :integer
#  transaction_origin       :string
#  transaction_category     :string
#  transaction_type         :string
#  customer_tag_uid         :string
#  operator_tag_uid         :string
#  station_id               :integer
#  device_uid               :string
#  device_db_index          :integer
#  device_created_at        :string
#  credits                  :float
#  refundable_credits       :float
#  credit_value             :float
#  final_balance            :float
#  final_refundable_balance :float
#  profile_id               :integer
#  status_code              :integer
#  status_message           :string
#  created_at               :datetime
#  updated_at               :datetime
#  gtag_counter             :integer          default(0)
#  counter                  :integer          default(0)
#

class CreditTransaction < Transaction
  has_many :sale_items
  belongs_to :profile

  accepts_nested_attributes_for :sale_items

  # TODO: Move all to Transaction  after Rails 5 which solves issue with scopes in abstract classes
  scope :with_event, -> (event) { where(event: event) }
  scope :with_customer_tag, -> (tag_uid) { where(customer_tag_uid: tag_uid) }
  scope :status_ok, -> { where(status_code: 0) }
  scope :origin, -> (origin) { where(transaction_origin: Transaction::ORIGINS[origin]) }
  scope :not_record_credit, -> { where.not(transaction_type: "record_credit") }

  default_scope { order([gtag_counter: :asc, counter: :asc, status_code: :desc]) }

  after_update :recalculate_profile_balance

  def recalculate_profile_balance
    binding.pry
    transactions = profile.credit_transactions.status_ok.not_record_credit

    if transactions.map(&:transaction_origin).uniq.first == "customer_portal"
      fb = transactions.sum(:credits)
      frb = transactions.sum(:refundable_credits)
    else
      fb = transactions.last.final_balance
      frb = transactions.last.final_refundable_balance
    end

    profile.update(credits: transactions.sum(:credits),
                   refundable_credits: transactions.sum(:refundable_credits),
                   final_balance: fb,
                   final_refundable_balance: frb)
  end

  def description
   refundables = " - R #{refundable_credits} #{event.token_symbol}" if credits != refundable_credits
   "#{transaction_type.humanize}: #{credits} #{event.token_symbol}#{refundables}"
  end

  def self.mandatory_fields
    super + %w( credits credits_refundable credit_value final_balance final_refundable_balance )
  end

  def self.column_names
    super + %w( sale_items_attributes )
  end
end
