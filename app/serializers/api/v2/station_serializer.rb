module Api::V2
  class StationSerializer < ActiveModel::Serializer
    attributes :id, :name, :group, :location, :category, :reporting_category, :address, :registration_num, :official_name, :hidden
    attribute :credits_sold, if: :pos_station?
    attribute :virtual_credits_sold, if: :pos_station?

    has_many :products, serializer: ProductSerializer

    def credits_sold
      object.credit_pos_sales_total(credit_filter: object.event.credit)
    end

    def virtual_credits_sold
      object.credit_pos_sales_total(credit_filter: object.event.virtual_credit)
    end

    def pos_station?
      object.category.in?(%w[bar vendor])
    end
  end
end
