module Api
  module V1
    module Events
      class ParametersController < Api::V1::EventsController
        before_action :set_modified

        # TODO: refactor, remove, i (jake) dont care, but this is not good code. This should be a call to events/:id
        def index # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity
          render(status: 304, json: :none) && return if @modified && @current_event.updated_at.httpdate <= @modified

          cols = %w[uid_reverse sync_time_gtags sync_time_tickets transaction_buffer days_to_keep_backup sync_time_customers fast_removal_password
                    private_zone_password sync_time_server_date sync_time_basic_download sync_time_event_parameters gtag_type maximum_gtag_balance
                    stations_apply_orders stations_initialize_gtags stations_apply_tickets tips_enabled]

          body = cols.map { |col| { name: col, value: @current_event.method(col).call } }

          dev_env = Rails.env.development? || Rails.env.test? || Rails.env.integration?
          fake_key = "11111111111111111111111111111111"
          value = dev_env ? fake_key : @current_event.gtag_key

          body << { name: "initial_topup_fee", value: @current_event.onsite_initial_topup_fee } if @current_event.onsite_initial_topup_fee.present?
          body << { name: "topup_fee", value: @current_event.every_topup_fee } if @current_event.every_topup_fee.present?
          body << { name: "gtag_deposit_fee", value: @current_event.gtag_deposit_fee } if @current_event.gtag_deposit_fee.present?

          body << { name: "ultralight_c_private_key", value: value } if @current_event.gtag_type.eql?("ultralight_c")
          body << { name: "gtag_key", value: value }
          body << { name: "cypher_enabled", value: @current_event.name.downcase.tr("ó", "o").include?("sonar") }

          serie = @current_event.event_serie
          old_events = serie ? serie.events.where.not(id: @current_event.id).map { |e| dev_env ? fake_key : e.gtag_key }.uniq.join(";") : "" # rubocop:disable Style/NestedTernaryOperator
          body << { name: "old_event_keys", value: old_events }

          render_entity(body.as_json, @current_event.updated_at&.httpdate)
        end
      end
    end
  end
end
