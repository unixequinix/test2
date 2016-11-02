class CredentialTransaction < Transaction
  belongs_to :ticket

  def description
    transaction_type.humanize
  end
end
