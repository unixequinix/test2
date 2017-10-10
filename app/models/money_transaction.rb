class MoneyTransaction < Transaction
  belongs_to :order, optional: true

  def self.mandatory_fields
    super + %w[items_amount price payment_method]
  end

  def description
    act = action.gsub("online_", "").gsub("onsite_", "").gsub("portal_", "").gsub("box_office_", "").humanize
    "#{act}: #{format('%20.2f', price)} #{event.currency_symbol}"
  end

  def self.policy_class
    TransactionPolicy
  end
end
