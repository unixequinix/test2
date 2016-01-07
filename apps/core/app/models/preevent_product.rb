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
  has_many :preevent_product_combos
  belongs_to :event
  has_many :tickets
end
