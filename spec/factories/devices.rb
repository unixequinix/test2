# == Schema Information
#
# Table name: devices
#
#  asset_tracker :string
#  created_at    :datetime         not null
#  device_model  :string
#  imei          :string
#  mac           :string
#  serial_number :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_devices_on_mac_and_imei_and_serial_number  (mac,imei,serial_number) UNIQUE
#

FactoryGirl.define do
  factory :device do
    device_model { "Rand #{rand(100)}" }
    imei { SecureRandom.hex(8).upcase }
    mac { SecureRandom.hex(8).upcase }
    serial_number { SecureRandom.hex(8).upcase }
  end
end
