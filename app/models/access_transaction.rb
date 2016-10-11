class AccessTransaction < Transaction
  belongs_to :access

  def self.mandatory_fields
    super + %w( access_id direction final_access_value )
  end

  def description
    "#{transaction_type.gsub('access', '').humanize}: #{access.catalog_item.name}"
  end
end
