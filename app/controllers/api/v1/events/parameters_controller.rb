class Api::V1::Events::ParametersController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    render(status: 304, json: :none) && return if @modified && @current_event.updated_at.httpdate <= @modified

    cols = %w[uid_reverse sync_time_gtags sync_time_tickets transaction_buffer days_to_keep_backup sync_time_customers fast_removal_password private_zone_password sync_time_server_date sync_time_basic_download sync_time_event_parameters gtag_type gtag_deposit_fee initial_topup_fee topup_fee maximum_gtag_balance stations_apply_orders stations_initialize_gtags] # rubocop:disable Metrics/LineLength
    cols += @current_event.attributes.keys.select { |k| k.to_s.starts_with? @current_event.gtag_type }.map(&:to_s)
    body = cols.map { |col| { name: col, value: @current_event.send(col) } }
    value = Rails.env.production? || Rails.env.demo? || Rails.env.hotfix? ? @current_event.gtag_key : "11111111111111111111111111111111"
    body << { name: "gtag_key", value: value }

    render_entity(body.as_json, @current_event.updated_at&.httpdate)
  end
end
