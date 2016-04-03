# == Schema Information
#
# Table name: order_transactions
#
#  id                           :integer          not null, primary key
#  event_id_id                  :integer
#  transaction_origin           :string
#  transaction_category         :string
#  transaction_type             :string
#  customer_tag_uid             :string
#  operator_tag_uid             :string
#  station_id_id                :integer
#  device_uid                   :string
#  device_db_index              :integer
#  device_created_at            :string
#  customer_order_id_id         :integer
#  catalog_item_id_id           :integer
#  customer_event_profile_id_id :integer
#  integer                      :string
#  status_message               :string
#

class OrderTransaction < Transaction
  belongs_to :customer_order
  belongs_to :catalog_item
end
