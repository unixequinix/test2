module Api::V2
  class PokeSerializer < ActiveModel::Serializer
    attributes :event_id, :action, :description, :operation_id, :source, :date, :line_counter, :gtag_counter, :device_id, :station_id, :customer_id, :customer_gtag_id, :operator_id, :operator_gtag_id, :credential_type, :credential_id, :ticket_type_id, :product_id, :order_id, :catalog_item_id, :catalog_item_type, :sale_item_quantity, :sale_item_unit_price, :sale_item_total_price, :standard_unit_price, :standard_total_price, :payment_method, :monetary_quantity, :monetary_unit_price, :monetary_total_price, :credit_type, :credit_id, :credit_name, :credit_amount, :final_balance, :message, :priority, :user_flag_value, :access_direction
  end
end
