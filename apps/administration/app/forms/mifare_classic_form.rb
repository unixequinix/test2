class MifareClassicForm
  include ActiveModel::Model
  include Virtus.model

  attribute :mifare_classic_public_key, String
  attribute :mifare_classic_private_key_a, String
  attribute :mifare_classic_private_key_b, String
  attribute :event_id, Integer

  validates_presence_of :mifare_classic_public_key
  validates_presence_of :mifare_classic_private_key_a
  validates_presence_of :mifare_classic_private_key_b
  validates_presence_of :event_id

  validates :mifare_classic_public_key,
            :mifare_classic_private_key_a,
            :mifare_classic_private_key_b, length: { is: 12 }

  validates :mifare_classic_public_key,
            :mifare_classic_private_key_a,
            :mifare_classic_private_key_b, format: { with: /\A[0-9A-F]+\z/,
                                                     message: "only allows hexadecimal values" }

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    Parameter.where(category: "gtag", group: "mifare_classic").each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end
