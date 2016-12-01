class Api::V1::Events::ProductsController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    products = current_event.products
    products = products.where("products.updated_at > ?", @modified) if @modified
    date = products.maximum(:updated_at)&.httpdate
    products = ActiveModelSerializers::Adapter.create(products.map { |a| Api::V1::ProductSerializer.new(a) }).to_json if products.present? # rubocop:disable Metrics/LineLength

    render_entity(products, date)
  end
end
