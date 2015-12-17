# == Schema Information
#
# Table name: order_items
#
#  id                :integer          not null, primary key
#  order_id          :integer          not null
#  online_product_id :integer          not null
#  amount            :integer
#  total             :decimal(8, 2)    not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require "rails_helper"

RSpec.describe OrderItem, type: :model do
  it do is_expected.to validate_numericality_of(:amount)
    .only_integer
    .is_less_than_or_equal_to(500)
  end
end
