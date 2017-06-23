class OrderTransaction < Transaction
  belongs_to :order, optional: true
  belongs_to :order_item, optional: true
  belongs_to :catalog_item, optional: true

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
