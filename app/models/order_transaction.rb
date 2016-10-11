class OrderTransaction < Transaction
  belongs_to :customer_order
  belongs_to :catalogable, polymorphic: true

  def self.mandatory_fields
    super + %w( catalogable_id catalogable_type )
  end
end
