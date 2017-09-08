class Api::V2::Full::StatSerializer < ActiveModel::Serializer
  attributes :id, :transaction_id, :transaction_counter, :source, :action, :product_qty, :product_name, :date, :total, :payment_method,
             :operator_tag_uid, :customer_tag_uid, :device_id, :product_id

  belongs_to :station, serializer: Api::V2::StationSerializer
  belongs_to :event, serializer: Api::V2::EventSerializer
end
