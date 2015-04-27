# == Schema Information
#
# Table name: orders
#
#  id                :integer          not null, primary key
#  customer_id       :integer          not null
#  online_product_id :integer          not null
#  number            :string           not null
#  amount            :decimal(8, 2)    not null
#  aasm_state        :string           not null
#  completed_at      :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Order < ActiveRecord::Base

  # Associations
  belongs_to :customer
  belongs_to :online_product

  # Validations
  validates :customer, :online_product, :number, :amount, :aasm_state, presence: true
end
