class CredentialTransaction < Transaction
  def description
    action.humanize
  end

  def self.policy_class
    TransactionPolicy
  end
end
