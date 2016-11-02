class DeviceTransaction < Transaction
  scope :status_ok, -> { where(status_code: 0) }
end
