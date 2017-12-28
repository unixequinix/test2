# rubocop:disable Metrics/PerceivedComplexity
module Api
  module V1
    module Events
      class ParametersController < Api::V1::Events::BaseController
        before_action :set_modified

        # TODO: refactor, remove, i (jake) dont care, but this is not good code. This should be a call to events/:id
        def index
          render(status: 304, json: :none) && return if @modified && @current_event.updated_at.httpdate <= @modified

          cols = %w[uid_reverse sync_time_gtags sync_time_tickets transaction_buffer days_to_keep_backup sync_time_customers fast_removal_password
                    private_zone_password sync_time_server_date sync_time_basic_download sync_time_event_parameters gtag_type gtag_deposit_fee
                    topup_fee initial_topup_fee maximum_gtag_balance stations_apply_orders stations_initialize_gtags all_stations_apply_tickets
                    tips_enabled]

          body = cols.map { |col| { name: col, value: @current_event.method(col).call } }

          dev_env = Rails.env.development? || Rails.env.test? || Rails.env.integration?
          fake_key = "11111111111111111111111111111111"
          value = dev_env ? fake_key : @current_event.gtag_key

          body << { name: "ultralight_c_private_key", value: value } if @current_event.gtag_type.eql?("ultralight_c")
          body << { name: "gtag_key", value: value }
          body << { name: "cypher_enabled", value: @current_event.name.downcase.tr("ó", "o").include?("sonar") }

          # rubocop:disable Style/NestedTernaryOperator
          serie = @current_event.event_serie
          old_events = serie ? serie.events.where.not(id: @current_event.id).map { |e| dev_env ? fake_key : e.gtag_key }.uniq.join(";") : ""
          body << { name: "old_event_keys", value: old_events }

          render_entity(body.as_json, @current_event.updated_at&.httpdate)
        end
      end
    end
  end
end
