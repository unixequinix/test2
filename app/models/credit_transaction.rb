class CreditTransaction < Transaction
  has_many :sale_items
  belongs_to :profile

  accepts_nested_attributes_for :sale_items

  default_scope { order([gtag_counter: :asc, counter: :asc, status_code: :desc]) }

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
