# == Schema Information
#
# Table name: preevent_products
#
#  id                   :integer          not null, primary key
#  event_id             :integer          not null
#  name                 :string
#  online               :boolean          default(FALSE), not null
#  initial_amount       :integer
#  step                 :integer
#  max_purchasable      :integer
#  min_purchasable      :integer
#  price                :decimal(, )
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  preevent_items_count :integer          default(0), not null
#

class PreeventProduct < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :event
  has_many :company_ticket_types
  has_many :preevent_product_items, dependent: :destroy
  has_many :preevent_items, through: :preevent_product_items, class_name: "PreeventItem"
  has_many :order_items
  has_many :orders, through: :order_items, class_name: "Order"

  accepts_nested_attributes_for :preevent_items
  accepts_nested_attributes_for :order_items
  accepts_nested_attributes_for :preevent_product_items, allow_destroy: true

  validates :event_id, :name, presence: true
  validates :preevent_items, length: { minimum: 1 }

  def rounded_price
    price.round == price ? price.floor : price
  end

  def preevent_items_counter(preevent_item_ids = nil)
    preevent_item_ids ?
      update_attribute(:preevent_items_count, preevent_item_ids.count) :
      update_attribute(:preevent_items_count, preevent_items.count)
  end

  def preevent_items_counter_decrement
    update_attribute(:preevent_items_count, preevent_items_count - 1)
  end

  def self.online_preevent_products_sortered(current_event)
    preevent_products = where(event_id: current_event.id)
    @sortered_products_storage = Hash[keys_sortered.map { |key| [key, []] }]

    preevent_products.each do |preevent_product|
      next unless preevent_product.online
      add_product_to_storage(preevent_product)
    end
    @sortered_products_storage.values.flatten
  end

  def self.keys_sortered
    %w(Credit Voucher CredentialType Pack)
  end

  def self.add_product_to_storage(preevent_product)
    category = preevent_product.get_product_category
    @sortered_products_storage[category] << preevent_product
  end

  def get_product_category
    is_a_pack? ? "Pack" : preevent_items.first.purchasable_type
  end

  def is_a_pack?
    preevent_items_count > 1
  end

  def is_immutable?
    preevent_items_count == 1 &&
    get_product_category == "Credit"
  end
end
