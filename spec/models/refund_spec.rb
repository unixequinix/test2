# == Schema Information
#
# Table name: refunds
#
#  id              :integer          not null, primary key
#  customer_id     :integer          not null
#  gtag_id         :integer          not null
#  bank_account_id :integer          not null
#  aasm_state      :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Refund, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
