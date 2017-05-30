class OperatorTransaction < Transaction
  belongs_to :operator_permission, optional: true, foreign_key: :catalog_item_id

  def description
    action.humanize
  end

  def self.mandatory_fields
    super + %w[operator_value operator_station_id]
  end

  def self.policy_class
    TransactionPolicy
  end
end
