class MoneyTransaction < Transaction
  belongs_to :catalogable, polymorphic: true

  def self.mandatory_fields
    super + %w( catalogable_id catalogable_type items_amount price payment_method )
  end

  def description
    "Payment: #{event.currency} #{format('%20.2f', price)}"
  end
end
