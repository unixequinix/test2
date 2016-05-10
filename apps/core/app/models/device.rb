# == Schema Information
#
# Table name: devices
#
#  id            :integer          not null, primary key
#  name          :string
#  imei          :string
#  mac           :string
#  serial_number :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Device < ActiveRecord::Base
end
