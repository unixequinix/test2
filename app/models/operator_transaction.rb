class OperatorTransaction < Transaction
  def self.mandatory_fields
    super + %w[operator_value operator_station_id]
  end

  def self.policy_class
    TransactionPolicy
  end
end
