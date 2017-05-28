class DeviceRegistration < ApplicationRecord
  belongs_to :device
  belongs_to :event

  attr_accessor :operator, :station, :last_time_used

  # REFACTOR: into 2 methods
  def status
    last_onsite = event.transactions.onsite.where(device_uid: device.mac).order(:device_created_at).last
    self.operator = last_onsite&.operator_tag_uid
    self.station = last_onsite&.station&.name
    self.last_time_used = last_onsite&.device_created_at

    case
      when (server_transactions != number_of_transactions) then "to_check"
      when action.in?(%w[pack_device lock_device]) then "locked"
      when server_transactions.zero? && number_of_transactions.zero? then "staged"
      when action.eql?("device_initialization") then "live"
      else "no_idea"
    end
  end
end
