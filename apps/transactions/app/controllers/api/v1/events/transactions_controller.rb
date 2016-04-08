class Api::V1::Events::TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :restrict_access_with_http

  def create
    render(status: :bad_request, json: :bad_request) && return unless params[:_json]

    atts_valid = params[:_json].map do |atts|
      all_required_params?(atts.keys.map(&:to_sym), atts[:transaction_category])
    end.flatten.uniq

    render(status: :unprocessable_entity, json: {
             errors: "missing keys: #{atts_valid.to_sentence}" }) && return unless atts_valid.empty?

    jobs_valid = params[:_json].all? do |atts|
      Jobs::Base.write(ActiveSupport::HashWithIndifferentAccess.new(atts)).valid?
    end

    render(status: :unprocessable_entity, json: "Job not proccessed") && return unless jobs_valid
    render(status: :created, json: :created)
  end

  private

  def all_required_params?(keys, category)
    return [:category] unless category
    mandatory = "#{category.camelcase}Transaction".constantize.mandatory_fields.map(&:to_sym)
    mandatory - keys
  end
end
