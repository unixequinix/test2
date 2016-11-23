# == Schema Information
#
# Table name: topup_credits
#
#  amount     :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_topup_credits_on_credit_id   (credit_id)
#  index_topup_credits_on_station_id  (station_id)
#
# Foreign Keys
#
#  fk_rails_c5b24eb933  (station_id => stations.id)
#

require "spec_helper"

RSpec.describe TopupCredit, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
