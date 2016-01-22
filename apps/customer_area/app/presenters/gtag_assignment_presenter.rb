class GtagAssignmentPresenter
  attr_accessor :current_event,
                :gtag_format,
                :gtag_name,
                :gtag_form_disclaimer

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
    self.gtag_format = current_event.get_parameter("gtag", "form", "format")
    self.gtag_name = current_event.gtag_name
    self.gtag_form_disclaimer = current_event.gtag_form_disclaimer
  end
end
