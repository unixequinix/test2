class MoneyTransaction < Transaction
  belongs_to :catalog_item
  belongs_to :order

  def self.mandatory_fields
    super + %w(catalog_item_id items_amount price payment_method)
  end

  def description
    act = credits.positive? ? "Payment" : "Cancellation"
    "#{act}: #{event.currency} #{format('%20.2f', price)}"
  end

  def self.policy_class
    TransactionPolicy
  end
end
