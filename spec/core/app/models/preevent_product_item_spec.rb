# == Schema Information
#
# Table name: preevent_product_items
#
#  id                  :integer          not null, primary key
#  preevent_item_id    :integer
#  preevent_product_id :integer
#  amount              :decimal(8, 2)    default(1.0), not null
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#


require "rails_helper"

RSpec.describe PreeventProductItem, type: :model do
end
