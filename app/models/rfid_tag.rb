# == Schema Information
#
# Table name: rfid_tags
#
#  id                :integer          not null, primary key
#  tag_uid           :string
#  tag_serial_number :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class RfidTag < ActiveRecord::Base

  # Associations
  has_many :rfid_tag_registrations
  has_one :registered_rfid_tag, ->{ where(aasm_state: :assigned) }, class_name: "RfidTagRegistration"
  has_many :customers, through: :rfid_tag_registrations
  has_one :registered_customer, ->{ where(rfid_tag_registrations: {aasm_state: :assigned}) }, class_name: "Customer"

  # Validations
  validates :tag_uid, :tag_serial_number, presence: true, uniqueness: true
end
