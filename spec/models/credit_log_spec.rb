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
  pending "add some examples to (or delete) #{__FILE__}"
end
