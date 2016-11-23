class Api::V1::Events::ParametersController < Api::V1::Events::BaseController
  def index
    gtag_settings = current_event.gtag_settings
    device_settings = current_event.device_settings
    gtag_common = current_event.gtag_settings.reject { |key| Gtag::DEFINITIONS.keys.include?(key.to_sym) }
    gtag_configs = gtag_common.merge(gtag_settings[gtag_settings["gtag_type"]])

    render json: device_settings.merge(gtag_configs)
  end
end
