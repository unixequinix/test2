class OperatorTransaction < Transaction
  belongs_to :operator_permission, optional: true, foreign_key: :catalog_item_id, inverse_of: :operator_transactions

  def description
    action.humanize
  end

  def self.policy_class
    TransactionPolicy
  end
end
