class CreditTransaction < Transaction
  has_many :sale_items, foreign_key: 'credit_transaction_id', inverse_of: :credit_transaction, dependent: :delete_all

  accepts_nested_attributes_for :sale_items

  scope :sales, -> { where(action: "sale") }

  def description
    action.humanize
  end

  def self.mandatory_fields
    super + %w[payments]
  end

  def self.column_names
    super + %w[sale_items_attributes]
  end

  def self.policy_class
    TransactionPolicy
  end
end
