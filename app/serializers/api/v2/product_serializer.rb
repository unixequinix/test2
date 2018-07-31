module Api::V2
  class ProductSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :is_alcohol, :vat, :price, :position

    attribute :credits_sold, if: :pos_station?
    attribute :virtual_credits_sold, if: :pos_station?
    attribute :quantity_sold, if: :pos_station?

    def credits_sold
      object.station.credit_pos_sales_total(credit_filter: object.station.event.credit, product_filter: object)
    end

    def virtual_credits_sold
      object.station.credit_pos_sales_total(credit_filter: object.station.event.virtual_credit, product_filter: object)
    end

    def quantity_sold
      object.station.count_pos_sales_total(product_filter: object)
    end

    def pos_station?
      object.station.category.in?(%w[bar vendor])
    end
  end
end
