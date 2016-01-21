# == Schema Information
#
# Table name: preevent_products
#
#  id              :integer          not null, primary key
#  event_id        :integer          not null
#  name            :string
#  online          :boolean          default(FALSE), not null
#  initial_amount  :integer
#  step            :integer
#  max_purchasable :integer
#  min_purchasable :integer
#  price           :decimal(, )
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class PreeventProduct < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :event
  has_many :company_ticket_types
  has_many :preevent_product_items
  has_many :preevent_items, through: :preevent_product_items, class_name: "PreeventItem"
  has_many :order_items
  has_many :orders, through: :order_items, class_name: "Order"

  accepts_nested_attributes_for :preevent_items
  accepts_nested_attributes_for :order_items
  accepts_nested_attributes_for :preevent_product_items, allow_destroy: true

  validates :event_id, :name, presence: true
end
