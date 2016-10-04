# == Schema Information
#
# Table name: order_transactions
#
#  id                   :integer          not null, primary key
#  event_id             :integer
#  transaction_origin   :string
#  transaction_category :string
#  transaction_type     :string
#  customer_tag_uid     :string
#  operator_tag_uid     :string
#  station_id           :integer
#  device_uid           :string
#  device_db_index      :integer
#  device_created_at    :string
#  customer_order_id    :integer
#  profile_id           :integer
#  status_message       :string
#  status_code          :integer
#  catalogable_type     :string
#  catalogable_id       :integer
#  created_at           :datetime
#  updated_at           :datetime
#  gtag_counter         :integer          default(0)
#  counter              :integer          default(0)
#

class OrderTransaction < Transaction
  belongs_to :customer_order
  belongs_to :catalogable, polymorphic: true

  def self.mandatory_fields
    super + %w( catalogable_id catalogable_type )
  end
end
