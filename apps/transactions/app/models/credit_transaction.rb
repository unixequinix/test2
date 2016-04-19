# == Schema Information
#
# Table name: credit_transactions
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
#  credits                   :float
#  credits_refundable        :float
#  credit_value              :float
#  final_balance             :float
#  final_refundable_balance  :float
#  customer_event_profile_id :integer
#  status_code               :integer
#  status_message            :string
#  created_at                :datetime
#  updated_at                :datetime
#

class CreditTransaction < Transaction
  has_many :sale_items

  accepts_nested_attributes_for :sale_items

  def self.mandatory_fields
    super + %w( credits credits_refundable credit_value final_balance final_refundable_balance )
  end
end
