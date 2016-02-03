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
  belongs_to :customer_event_profile
  belongs_to :preevent_product
  belongs_to :event
  belongs_to :ticket
  belongs_to :station
  belongs_to :device

  validates_presence_of :transaction_type

  def self.write(transaction_category, atts)
    klass = "#{transaction_category}_transaction".camelcase.constantize
    instance = klass.create!(atts)
    klass.delay.execute_actions instance.id
    instance
  end

  def self.execute_actions(id)
    instance = find(id)
    klass = instance.type.camelcase.constantize
    transaction do
      actions = [klass::SUBSCRIPTIONS[instance.transaction_type.to_sym]].flatten
      actions.each { |action| instance.method(action).call }
    end
  end
end
