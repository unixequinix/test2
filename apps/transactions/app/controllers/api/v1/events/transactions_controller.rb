class Api::V1::Events::TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :restrict_access_with_http

  def create
    render(status: :bad_request, json: :bad_request) && return unless params[:_json]

    all_valid = params[:_json].all? do |atts|
      all_required_params?(atts.keys, atts[:transaction_category]) && Jobs::Base.write(atts).valid?
    end

    render(status: :unprocessable_entity, json: :unprocessable_entity) && return unless all_valid
    render(status: :created, json: :created)
  end

  private

  def all_required_params?(keys, category)
    return false unless category
    mandatory = "#{category.camelcase}Transaction".constantize.mandatory_fields.map(&:to_sym)
    (mandatory - keys).empty?
  end
end
