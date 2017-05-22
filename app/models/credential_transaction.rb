class CredentialTransaction < Transaction
  belongs_to :ticket

  def credentials
    [gtag, ticket].compact
  end

  def description
    action.humanize
  end

  def self.policy_class
    TransactionPolicy
  end
end
