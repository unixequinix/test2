# == Schema Information
#
# Table name: transactions
#
#  id                        :integer          not null, primary key
#  type                      :string           not null
#  event_id                  :integer
#  transaction_type          :string
#  device_created_at         :datetime
#  ticket_id                 :integer
#  customer_tag_uid          :string
#  operator_tag_uid          :string
#  station_id                :integer
#  device_id                 :integer
#  device_uid                :integer
#  preevent_product_id       :integer
#  customer_event_profile_id :integer
#  payment_method            :string
#  amount                    :float            default(0.0)
#  status_code               :string
#  status_message            :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Transaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :customer_event_profile

  def self.write(type, atts)
    klass = type.camelcase.constantize
    klass.create atts
  end

  def self.delay_write(type, atts)
    klass = type.camelcase.constantize
    klass.delay.create atts
  end
end
