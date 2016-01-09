# == Schema Information
#
# Table name: preevent_product_units
#
#  id               :integer          not null, primary key
#  purchasable_id   :integer          not null
#  purchasable_type :string           not null
#  event_id         :integer
#  name             :string
#  description      :text
#  initial_amount   :integer
#  price            :decimal(, )
#  step             :integer
#  max_purchasable  :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class PreeventProductUnit < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :purchasable, polymorphic: true, touch: true
  belongs_to :event

  # Validations
  validates :name, presence: true
end
