# == Schema Information
#
# Table name: ban_transactions
#
#  id                 :integer          not null, primary key
#  event_id           :integer
#  transaction_origin :string
#  transaction_type   :string
#  station_id         :integer
#  profile_id         :integer
#  device_uid         :string
#  device_db_index    :integer
#  device_created_at  :string
#  customer_tag_uid   :string
#  operator_tag_uid   :string
#  banneable_id       :integer          not null
#  banneable_type     :string           not null
#  reason             :text
#  status_code        :integer
#  status_message     :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class BanTransaction < Transaction
  belongs_to :banneable, polymorphic: true

  def self.mandatory_fields
    super + %w( reason )
  end
end
