class UserFlagTransaction < Transaction
  def self.mandatory_fields
    super + %w[user_flag user_flag_active]
  end

  def self.policy_class
    TransactionPolicy
  end
end
