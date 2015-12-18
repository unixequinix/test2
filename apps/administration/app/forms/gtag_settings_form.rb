class GtagSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :format, String
  attribute :event_id, Integer
  attribute :gtag_name, String
  attribute :gtag_form_disclaimer
  attribute :gtag_assignation_notification

  validates_presence_of :format
  validates_presence_of :event_id
  validates_presence_of :gtag_name
  validates_presence_of :gtag_form_disclaimer
  validates_presence_of :gtag_assignation_notification

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def gtag_formats
    Gtag::FORMATS
  end


  private

  def persist!
    Parameter.where(category: "gtag", group: "form").each do |parameter|
      ep = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
      ep.nil? ? EventParameter.create!(value: attributes[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) : ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end
