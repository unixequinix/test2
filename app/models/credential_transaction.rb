class CredentialTransaction < Transaction
  belongs_to :ticket

  def description
    action.humanize
  end

  def self.policy_class
    TransactionPolicy
  end
end
