# == Schema Information
#
# Table name: device_transactions
#
#  action                  :string
#  device_db_index         :integer
#  initialization_type     :string
#  number_of_transactions  :integer
#  status_code             :integer          default(0)
#  status_message          :string
#
# Indexes
#
#  index_device_transactions_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_d4bd5146d8  (event_id => events.id)
#

FactoryGirl.define do
  factory :device_transaction do
    action "device_initialization"
    device_uid { "DEVICE##{rand(100)}" }
  end
end
