# == Schema Information
#
# Table name: vouchers
#
#  id         :integer          not null, primary key
#  counter    :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe Voucher, type: :model do
end
