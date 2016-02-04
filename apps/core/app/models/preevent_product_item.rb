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

class PreeventProductItem < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :preevent_product, counter_cache: :preevent_items_count
  belongs_to :preevent_item

  accepts_nested_attributes_for :preevent_item
end
