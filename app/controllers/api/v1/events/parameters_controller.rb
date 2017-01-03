class Api::V1::Events::ParametersController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    render(status: 304, json: :none) && return if @modified && @current_event.updated_at.httpdate <= @modified

    cols = %w(uid_reverse sync_time_gtags sync_time_tickets transaction_buffer days_to_keep_backup sync_time_customers fast_removal_password private_zone_password sync_time_server_date topup_initialize_gtag pos_update_online_orders sync_time_basic_download sync_time_event_parameters touchpoint_update_online_orders gtag_format gtag_type gtag_deposit gtag_deposit_fee topup_fee card_return_fee cards_can_refund maximum_gtag_balance wristbands_can_refund) # rubocop:disable Metrics/LineLength
    cols += @current_event.attributes.keys.select { |k| k.to_s.starts_with? @current_event.gtag_type }.map(&:to_s)

    body = cols.map { |col| { name: col, value: @current_event.send(col) } }

    render_entity(body.as_json, @current_event.updated_at&.httpdate)
  end
end
