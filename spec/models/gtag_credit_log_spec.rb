# == Schema Information
#
# Table name: gtag_credit_logs
#
#  id         :integer          not null, primary key
#  gtag_id    :integer          not null
#  amount     :decimal(8, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe GtagCreditLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
