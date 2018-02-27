module EventsHelper
  def best_in_place_checkbox(url)
    yes = render "layouts/checkbox_yes"
    no = render "layouts/checkbox_no"
    { collection: { false: no, true: yes }, place_holder: no, as: :checkbox, url: url, activator: false } # rubocop:disable Lint/BooleanSymbol
  end

  def associated_device_registration(event, device)
    DeviceRegistration.find_by(event: event, device: device)
  end

  def analytics_message(event)
    "Data shown here could not be 100% accurate until all devices are synced & locked" if event.state.eql?('launched')
  end
end
