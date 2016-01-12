# == Schema Information
#
# Table name: preevent_products
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  name       :string
#  online     :boolean          default(FALSE), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PreeventProduct < ActiveRecord::Base
  acts_as_paranoid

  has_many :tickets
  belongs_to :event
  has_many :preevent_product_items
  has_many :preevent_items, through: :preevent_product_items, class_name: 'PreeventItem'

  accepts_nested_attributes_for :preevent_items
  accepts_nested_attributes_for :preevent_product_items, allow_destroy: true

  validates :event_id, :name, presence: true
end
