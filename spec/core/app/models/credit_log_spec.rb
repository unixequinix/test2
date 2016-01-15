# == Schema Information
#
# Table name: credit_logs
#
#  id                        :integer          not null, primary key
#  transaction_type          :string
#  amount                    :decimal(8, 2)    not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_event_profile_id :integer
#

require 'rails_helper'

RSpec.describe CreditLog, type: :model do
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_presence_of(:transaction_type) }
  it { is_expected.to validate_presence_of(:customer_event_profile) }
end
