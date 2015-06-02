# == Schema Information
#
# Table name: orders
#
#  id           :integer          not null, primary key
#  customer_id  :integer          not null
#  number       :string           not null
#  aasm_state   :string           not null
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Order, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
