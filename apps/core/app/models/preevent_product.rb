# == Schema Information
#
# Table name: preevent_products
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  name       :string
#  online     :boolean
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PreeventProduct < ActiveRecord::Base
  acts_as_paranoid

  has_many :tickets
  belongs_to :event
  has_many :preevent_product_combos
  has_many :preevent_product_units, through: :preevent_product_combos, class_name: 'PreeventProductUnit'

  accepts_nested_attributes_for :preevent_product_units
  accepts_nested_attributes_for :preevent_product_combos, :allow_destroy => true

  validates :event_id, :name, :online, presence: true
end
