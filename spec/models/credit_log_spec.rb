# == Schema Information
#
# Table name: credit_logs
#
#  id               :integer          not null, primary key
#  customer_id      :integer          not null
#  transaction_type :string
#  amount           :decimal(8, 2)    not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe CreditLog, type: :model do
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_presence_of(:transaction_type) }
  it { is_expected.to validate_presence_of(:customer_event_profile) }
end
