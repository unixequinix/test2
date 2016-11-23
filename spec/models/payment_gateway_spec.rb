# == Schema Information
#
# Table name: payment_gateways
#
#  created_at :datetime         not null
#  data       :json
#  gateway    :string
#  refund     :boolean
#  topup      :boolean
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payment_gateways_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_9c9a24f555  (event_id => events.id)
#

require 'spec_helper'

RSpec.describe PaymentGateway, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
