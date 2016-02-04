class UltralightEv1Form
  include ActiveModel::Model
  include Virtus.model

  attribute :ultralight_ev1_private_key, String
  attribute :event_id, Integer

  validates_presence_of :ultralight_ev1_private_key
  validates_presence_of :event_id


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
    Parameter.where(category: "gtag", group: "ultralight_ev1").each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end
