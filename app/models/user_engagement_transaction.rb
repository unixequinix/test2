class UserEngagementTransaction < Transaction
  def self.mandatory_fields
    super + %w( message priority )
  end
end
