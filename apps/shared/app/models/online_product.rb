# == Schema Information
#
# Table name: online_products
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  description      :string           not null
#  price            :decimal(8, 2)    not null
#  purchasable_id   :integer          not null
#  purchasable_type :string           not null
#  min_purchasable  :integer
#  max_purchasable  :integer
#  initial_amount   :integer
#  step             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  event_id         :integer          not null
#

class OnlineProduct < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  belongs_to :event
  belongs_to :purchasable, polymorphic: true, touch: true
  has_many :order_items

  # Validations
  validates :name, :description, :price, :min_purchasable,
            :max_purchasable, :initial_amount, :step, presence: true

  def rounded_price
    self.price.round == self.price ? self.price.floor : self.price
  end
end
