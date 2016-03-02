# == Schema Information
#
# Table name: money_transactions
#
#  id                        :integer          not null, primary key
#  event_id                  :integer
#  transaction_origin        :string
#  transaction_category      :string
#  transaction_type          :string
#  customer_tag_uid          :string
#  operator_tag_uid          :string
#  station_id                :integer
#  device_uid                :string
#  device_db_index           :integer
#  device_created_at         :datetime
#  catalogable_id            :integer
#  catalogable_type          :string
#  items_amount              :integer
#  price                     :float
#  payment_method            :string
#  payment_gateway           :string
#  customer_event_profile_id :integer
#  status_code               :integer
#  status_message            :string
#

class MoneyTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :device
  belongs_to :customer_event_profile
  has_many :line_items
  has_many :transaction_sale_items

  validates_presence_of :transaction_type

  accepts_nested_attributes_for :transaction_sale_items
end
