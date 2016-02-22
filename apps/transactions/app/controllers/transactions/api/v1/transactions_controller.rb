class Transactions::Api::V1::TransactionsController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :restrict_access_with_http

  serialization_scope :view_context

  def create
    all_valid = params[:_json].map do |transaction_params|
      category, atts = pre_process(transaction_params)
      Jobs::Base.write(category, atts).valid?
    end

    render status: 400, json: :bad_request && return unless all_valid.all?
    render status: 201, json: :created
  end

  private

  def pre_process(atts)
    category = atts.delete(:transaction_category)
    atts.delete(:ticket_code)

    [category, atts]
  end
end
