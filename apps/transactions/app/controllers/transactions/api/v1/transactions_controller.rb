class Transactions::Api::V1::TransactionsController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :restrict_access_with_http

  serialization_scope :view_context

  def create
    all_valid = permitted_params[:_json].map do |transaction_params|
      category, atts = pre_process(transaction_params)
      Jobs::Base.write(category, atts).valid?
    end

    render(status: 400, json: :bad_request) && return unless all_valid.all?
    render(status: 201, json: :created)
  end

  private

  def pre_process(atts)
    category = atts.delete(:transaction_category)
    atts.delete(:ticket_code)

    [category, atts]
  end

  # rubocop:disable Metrics/MethodLength
  def permitted_params
    params.permit(_json: [:transaction_category,
                          :direction,
                          :access_entitlement_id,
                          :access_entitlement_value,
                          :credits,
                          :credits_refundable,
                          :value_credit,
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
