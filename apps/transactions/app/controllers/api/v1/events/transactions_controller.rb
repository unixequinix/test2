class Api::V1::Events::TransactionsController < Api::V1::BaseController
  def create
    all_good = params[:_json].map do |transaction|
      category = transaction.delete("transaction_category")
      unlocked_params = ActiveSupport::HashWithIndifferentAccess.new(transaction)
      Transactions::Jobs::Base.write(category, unlocked_params).valid?
    end

    render status: 400, json: :bad_request && return unless all_good.all?
    render status: 201, json: :created
  end
end
