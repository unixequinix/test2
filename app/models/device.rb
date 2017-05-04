class Device < ActiveRecord::Base
  has_many :device_registrations
  has_many :events, through: :device_registrations

  attr_accessor :msg, :count_diff, :action, :status, :operator, :station, :last_time_used
end
