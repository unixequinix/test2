class Api::V1::Events::ProductsController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    products = @current_event.products
    products = products.where("products.updated_at > ?", @modified) if @modified
    date = products.maximum(:updated_at)&.httpdate
    products = products.map { |a| Api::V1::ProductSerializer.new(a) }.as_json if products.present?

    render_entity(products, date)
  end
end
