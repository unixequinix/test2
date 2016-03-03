# == Schema Information
#
# Table name: customer_credits
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  amount                    :decimal(, )      not null
#  refundable_amount         :decimal(, )      not null
#  final_balance             :decimal(, )      not null
#  final_refundable_balance  :decimal(, )      not null
#  credit_value              :decimal(, )      not null
#  payment_method            :string           not null
#  transaction_source         :string           not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require "rails_helper"

RSpec.describe CustomerCredit, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
