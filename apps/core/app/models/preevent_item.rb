# == Schema Information
#
# Table name: preevent_items
#
#  id               :integer          not null, primary key
#  purchasable_id   :integer          not null
#  purchasable_type :string           not null
#  event_id         :integer
#  name             :string
#  description      :text
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class PreeventItem < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :purchasable, polymorphic: true, touch: true
  belongs_to :event
  has_many :preevent_product_items
  has_many :preevent_products, through: :preevent_product_items, class_name: "PreeventProduct"

  # Validations
  validates :name, presence: true
end
