# == Schema Information
#
# Table name: devices
#
#  asset_tracker :string
#  device_model  :string
#  imei          :string           indexed => [mac, serial_number]
#  mac           :string           indexed => [imei, serial_number]
#  serial_number :string           indexed => [mac, imei]
#
# Indexes
#
#  index_devices_on_mac_and_imei_and_serial_number  (mac,imei,serial_number) UNIQUE
#

class Device < ActiveRecord::Base
  before_validation :upcase_asset_tracker!

  def upcase_asset_tracker!
    asset_tracker&.upcase!
  end
end
