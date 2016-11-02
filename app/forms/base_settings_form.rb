class BaseSettingsForm
  include ActiveModel::Model
  include Virtus.model

  INPUT_FORMATS = { boolean: :radio_buttons, string: :string }.freeze
  INPUT_EXCEPTIONS = [:country].freeze

  def save(_params, _request)
    if valid?
      persist!
      true
    else
      false
    end
  end

  def update
    if valid?
      persist!
      true
    else
      false
    end
  end

  def self.attribute_type(attribute_name)
    attribute = attribute_set[attribute_name]
    return nil if INPUT_EXCEPTIONS.include?(attribute.name)
    INPUT_FORMATS[attribute.type.to_s.gsub("Axiom::Types::", "").downcase.to_sym]
  end

  def main_parameters
    attributes.keys.reject { |value| value == :event_id }
  end

  private

  def persist_parameters(parameters)
    parameters.each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym].to_s)
    end
  end
end
