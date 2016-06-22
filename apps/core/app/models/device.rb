# == Schema Information
#
# Table name: devices
#
#  id            :integer          not null, primary key
#  device_model  :string
#  imei          :string
#  mac           :string
#  serial_number :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  asset_tracker :string
#

class Device < ActiveRecord::Base
end
