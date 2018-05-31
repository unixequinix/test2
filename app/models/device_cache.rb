class DeviceCache < ApplicationRecord
  belongs_to :event

  validates :category, :app_version, presence: true
  validates :file, attachment_presence: true
  do_not_validate_attachment_file_type :file

  has_attached_file(:file, path: "gspot/event/:event_id/device_caches/:app_version/:category.:extension", use_timestamp: false)
end
