class Api::V1::Events::CustomersController < Api::V1::Events::BaseController
  def index
    modified = request.headers["If-Modified-Since"]
    customers = sql_customers(modified) || []

    if customers.present?
      date = JSON.parse(customers).map { |pr| pr["updated_at"] }.sort.last
      response.headers["Last-Modified"] = date.to_datetime.httpdate
    end

    status = customers.present? ? 200 : 304 if modified
    status ||= 200

    render(status: status, json: customers)
  end

  def show
    customer = current_event.customers.find_by(id: params[:id])

    render(status: :not_found, json: :not_found) && return unless customer
    render(json: customer, serializer: Api::V1::CustomerSerializer)
  end
end
