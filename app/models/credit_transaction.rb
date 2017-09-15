class CreditTransaction < Transaction
  has_many :sale_items, foreign_key: 'credit_transaction_id', inverse_of: :credit_transaction, dependent: :delete_all

  accepts_nested_attributes_for :sale_items

  def description
    refundables = " - R #{refundable_credits} #{event.credit.symbol}" if credits != refundable_credits
    "#{action.humanize}: #{credits} #{event.credit.symbol} #{refundables}"
  end

  def self.mandatory_fields
    super + %w[credits refundable_credits credit_value final_balance final_refundable_balance]
  end

  def self.column_names
    super + %w[sale_items_attributes]
  end

  def self.policy_class
    TransactionPolicy
  end
end
