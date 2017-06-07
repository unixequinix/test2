class AccessTransaction < Transaction
  belongs_to :access, optional: true

  def self.mandatory_fields
    super + %w[access_id direction final_access_value]
  end

  def description
    "#{action.gsub('access', '').humanize}: #{access.name}"
  end

  def self.policy_class
    TransactionPolicy
  end
end
