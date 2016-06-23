# == Schema Information
#
# Table name: device_transactions
#
#  id                     :integer          not null, primary key
#  event_id               :integer
#  transaction_origin     :string
#  transaction_category   :string
#  transaction_type       :string
#  customer_tag_uid       :string
#  operator_tag_uid       :string
#  station_id             :integer
#  device_uid             :string
#  device_db_index        :integer
#  device_created_at      :string
#  initialization_type    :string
#  number_of_transactions :integer
#  profile_id             :integer
#  status_code            :integer
#  status_message         :string
#  created_at             :datetime
#  updated_at             :datetime
#  gtag_counter           :integer          default(0)
#  counter                :integer          default(0)
#

class DeviceTransaction < Transaction
end
