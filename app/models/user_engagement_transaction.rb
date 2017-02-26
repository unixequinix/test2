class UserEngagementTransaction < Transaction
  def self.mandatory_fields
    super + %w(message priority)
  end

  def self.policy_class
    TransactionPolicy
  end
end
