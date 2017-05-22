class MoneyTransaction < Transaction
  belongs_to :catalog_item, optional: true
  belongs_to :order, optional: true

  def self.mandatory_fields
    super + %w[items_amount price payment_method]
  end

  def description
    act = action.gsub("online_", "").gsub("onsite_", "").gsub("portal_", "").gsub("box_office_", "").humanize
    "#{act}: #{event.currency} #{format('%20.2f', price)}"
  end

  def self.policy_class
    TransactionPolicy
  end
end
