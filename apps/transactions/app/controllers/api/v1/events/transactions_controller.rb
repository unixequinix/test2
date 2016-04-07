class Api::V1::Events::TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :restrict_access_with_http
  serialization_scope :view_context

  def create
    render(status: :bad_request, json: :bad_request) && return unless permitted_params[:_json]

    all_valid = permitted_params[:_json].map do |transaction_params|
      Jobs::Base.write(transaction_params).valid?
    end

    render(status: :unprocessable_entity,
           json: :unprocessable_entity) && return unless all_valid.all?
    render(status: :created, json: :created)
  end

  private

  def permitted_params # rubocop:disable Metrics/MethodLength
    params.permit(_json: [:event_id,
                          :transaction_origin,
                          :transaction_category,
                          :transaction_type,
                          :customer_tag_uid,
                          :operator_tag_uid,
                          :station_id,
                          :device_uid,
                          :device_db_index,
                          :device_created_at,
                          :customer_event_profile_id,
                          :status_code,
                          :status_message,
                          :ticket_code,
                          :customer_order_id,
                          :catalogable_id,
                          :catalogable_type,
                          :items_amount,
                          :price,
                          :payment_method,
                          :payment_gateway,
                          :credits,
                          :credits_refundable,
                          :credit_value,
                          :final_balance,
                          :final_refundable_balance,
                          :sales_details,
                          :credits,
                          :credits_refundable,
                          :value_credit])
  end
end
