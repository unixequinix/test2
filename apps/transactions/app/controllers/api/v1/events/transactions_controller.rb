class Api::V1::Events::TransactionsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :restrict_access_with_http
  serialization_scope :view_context

  def create
    render(status: :bad_request, json: :bad_request) && return unless permitted_params[:_json]

    all_valid = permitted_params[:_json].map do |transaction_params|
      Jobs::Base.write(transaction_params).valid?
    end

    render(status: :bad_request, json: :bad_request) && return unless all_valid.all?
    render(status: :created, json: :created)
  end

  private

  def permitted_params # rubocop:disable Metrics/MethodLength
    params.permit(_json: [:transaction_category,
                          :direction,
                          :access_entitlement_id,
                          :access_entitlement_value,
                          :credits,
                          :credits_refundable,
                          :credit_value,
                          :payment_gateway,
                          :payment_method,
                          :final_balance,
                          :final_refundable_balance,
                          :event_id,
                          :transaction_type,
                          :device_created_at,
                          :customer_tag_uid,
                          :operator_tag_uid,
                          :station_id,
                          :device_db_index,
                          :customer_event_profile_id,
                          :status_code,
                          :status_message,
                          :device_uid,
                          :ticket_code,
                          :preevent_product_id])
  end
end
