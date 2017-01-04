class Api::V1::Events::DeviceTransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :restrict_access_with_http

  def create # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    render(status: :bad_request, json: :bad_request) && return unless params[:_json]
    errors = { atts: [] }

    params[:_json].each_with_index do |atts, index|
      atts[:device_created_at_fixed] = atts[:device_created_at]
      att_errors = validate_params(atts.keys, index)
      errors[:atts] << att_errors && next if att_errors
      new_atts = atts.slice(:device_created_at_fixed, :device_db_index, :device_uid, :event_id, :status_code, :action)
      next if DeviceTransaction.find_by(new_atts.to_unsafe_h.symbolize_keys)
      DeviceTransaction.create!(atts.permit!)
    end

    errors.delete_if { |_, v| v.compact.empty? }
    render(status: :unprocessable_entity, json: { errors: errors }) && return if errors.any?
    render(status: :created, json: :created)
  end

  private

  def validate_params(keys, index)
    mandatory = DeviceTransaction.mandatory_fields
    missing = (mandatory.map(&:to_sym) - keys.map(&:to_sym)).to_sentence
    "Missing keys for position #{index}: #{missing}" unless missing.blank?
  end
end
