class BlacklistTransaction < Transaction
  belongs_to :blacklisted, polymorphic: true

  def self.mandatory_fields
    super + %w( reason )
  end
end
