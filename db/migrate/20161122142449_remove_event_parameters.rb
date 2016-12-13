class EventParameter < ActiveRecord::Base
  belongs_to :event
  belongs_to :parameter
end

class Parameter < ActiveRecord::Base
  has_many :event_parameters
  has_many :events, through: :event_parameters
end

class RemoveEventParameters < ActiveRecord::Migration
  def change
    Event.all.each do |event|
      parameters = EventParameter.where(event: event).joins(:parameter)

      device_params = parameters.where(parameters: { category: "device" })
      device_settings = {}
      device_params.each { |param| device_settings[param.parameter.name] = param.value }

      gtag_params = parameters.where(parameters: { category: "gtag", group: "form" })
      gtag_keys = parameters.where(parameters: { category: "gtag" }).where.not(parameters: { group: "form" })
      gtag_settings = {}
      gtag_params.each { |param| gtag_settings[param.parameter.name] = param.value }
      gtag_keys.each do |param|
        gtag_settings[param.parameter.group] ||= {}
        gtag_settings[param.parameter.group][param.parameter.name] = param.value
      end

      event.update!(device_settings: device_settings, gtag_settings: gtag_settings)
    end
  end
end
