class OperatorTransaction < Transaction
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
