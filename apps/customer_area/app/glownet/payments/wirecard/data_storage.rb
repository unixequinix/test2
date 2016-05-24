module Payments::Wirecard::DataStorage
  extend ActiveSupport::Concern

  def initialize(event, order)
    super(event, order)
    @data_storage = Payments::WirecardDataStorageInitializer.new(
      customer_id: customer_id,
      order_ident: order_ident,
      return_url: return_url,
      language: language,
      shop_id: shop_id,
      secret_key: secret_key
    ).data_storage
  end

  def with_params(params)
    super(params)
    @storage_id = params[:storage_id]
    self
  end

  attr_reader :data_storage

  def data_storage_id
    @storate_id || @data_storage["storageId"]
  end

  def data_storage_javascript_url
    @data_storage["javascriptUrl"]
  end

  def parameters
    super.merge(storageId: "data_storage_id")
  end
end
