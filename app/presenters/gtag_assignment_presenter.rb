class GtagAssignmentPresenter
  attr_accessor :current_event, :gtag_format, :gtag_form_disclaimer

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
    self.gtag_format = @current_event.gtag_format&.downcase
    self.gtag_form_disclaimer = @current_event.gtag_form_disclaimer
  end
end
