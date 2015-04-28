# == Schema Information
#
# Table name: orders
#
#  id           :integer          not null, primary key
#  customer_id  :integer          not null
#  number       :string           not null
#  aasm_state   :string           not null
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Order < ActiveRecord::Base

  # Associations
  belongs_to :customer
  has_many :order_items

  # Validations
  validates :customer, :order_items, :number, :price, :aasm_state, presence: true
end
