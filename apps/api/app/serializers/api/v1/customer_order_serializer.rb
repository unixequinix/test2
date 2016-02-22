class Api::V1::CustomerOrderSerializer < Api::V1::BaseSerializer
  attributes :gtag_version, :product

  def gtag_version
    object.counter
  end

  def product
    object.preevent_product_id
  end
end
