class Api::V1::Events::ParametersController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    gtag_base = @current_event.gtag_settings
    gtag_common = gtag_base.reject { |key| Gtag::DEFINITIONS.keys.include?(key.to_sym) }

    gtag_settings = gtag_common.merge(gtag_base[gtag_base["gtag_type"]]).map { |k, v| { name: k, value: v } }
    device_settings = @current_event.device_settings.map { |k, v| { name: k, value: v } }

    render(status: 200, json: device_settings + gtag_settings)
  end
end
