class Api::V2::Full::StatSerializer < ActiveModel::Serializer
  attributes %i[action name operation_id origin date event_id event_name line_counter device_id device_mac device_name station_id station_type
                station_name operator_uid operator_name event_series_id event_series_name customer_id customer_name customer_email customer_uid
                gtag_counter credential_code credential_type purchaser_name purchaser_email ticket_type_id ticket_type_name company_id company_name
                product_id product_name is_alcohol sale_item_quantity sale_item_unit_price sale_item_total_price catalog_item_id catalog_item_name
                catalog_item_type payment_method monetary_quantity monetary_unit_price currency monetary_total_price credit_id credit_name
                credit_value credit_amount final_balance order_id message priority user_flag_value access_direction]
end
