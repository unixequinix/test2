class OrderTransaction < Transaction
  belongs_to :order
  belongs_to :order_item
  belongs_to :catalog_item

  def description
    action.humanize
  end

  def self.mandatory_fields
    super + %w[catalog_item_id]
  end

  def self.policy_class
    TransactionPolicy
  end
end
