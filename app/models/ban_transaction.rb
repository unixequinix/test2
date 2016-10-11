class BanTransaction < Transaction
  belongs_to :banneable, polymorphic: true

  def self.mandatory_fields
    super + %w( reason )
  end
end
