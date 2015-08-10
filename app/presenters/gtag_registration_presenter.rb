class GtagRegistrationPresenter
  attr_accessor :current_event,
                :gtag_format,
                :gtag_form_disclaimer


  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
    self.gtag_format = EventParameter.find_by(event_id: current_event.id, parameter_id: Parameter.find_by(category: 'gtag', group: 'form', name: 'format')).value
    self.gtag_form_disclaimer = current_event.gtag_form_disclaimer
  end

end