# rubocop:disable Metrics/PerceivedComplexity
class Api::V1::Events::ParametersController < Api::V1::Events::BaseController
  before_action :set_modified

  # TODO: refactor, remove, i (jake) dont care, but this is not good code. This should be a call to events/:id
  def index # rubocop:disable Metrics/CyclomaticComplexity
    render(status: 304, json: :none) && return if @modified && @current_event.updated_at.httpdate <= @modified

    cols = %w[uid_reverse sync_time_gtags sync_time_tickets transaction_buffer days_to_keep_backup sync_time_customers fast_removal_password
              private_zone_password sync_time_server_date sync_time_basic_download sync_time_event_parameters gtag_type gtag_deposit_fee
              initial_topup_fee topup_fee maximum_gtag_balance stations_apply_orders stations_initialize_gtags all_stations_apply_tickets]

    body = cols.map { |col| { name: col, value: @current_event.method(col).call } }
    production_env = Rails.env.production? || Rails.env.demo? || Rails.env.hotfix? || Rails.env.staging?
    fake_key = "11111111111111111111111111111111"
    value = production_env ? @current_event.gtag_key : fake_key

    body << { name: "ultralight_c_private_key", value: value } if @current_event.gtag_type.eql?("ultralight_c")
    body << { name: "gtag_key", value: value }
    body << { name: "cypher_enabled", value: @current_event.name.downcase.tr("ó", "o").include?("sonar") }

    # rubocop:disable Style/NestedTernaryOperator
    serie = @current_event.event_serie
    old_events = serie ? serie.events.where.not(id: @current_event.id).map { |e| production_env ? e.gtag_key : fake_key }.uniq.join(";") : ""
    body << { name: "old_event_keys", value: old_events }

    render_entity(body.as_json, @current_event.updated_at&.httpdate)
  end
end
