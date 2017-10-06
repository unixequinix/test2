class OrderTransaction < Transaction
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
