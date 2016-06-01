# == Schema Information
#
# Table name: money_transactions
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
#  catalogable_id       :integer
#  catalogable_type     :string
#  items_amount         :float
#  price                :float
#  payment_method       :string
#  payment_gateway      :string
#  profile_id           :integer
#  status_code          :integer
#  status_message       :string
#  created_at           :datetime
#  updated_at           :datetime
#  gtag_counter         :integer          default(0)
#  counter              :integer          default(0)
#

class MoneyTransaction < Transaction
  belongs_to :catalogable, polymorphic: true

  def self.mandatory_fields
    super + %w( catalogable_id catalogable_type items_amount price payment_method )
  end
end
