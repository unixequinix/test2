# == Schema Information
#
# Table name: online_products
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  amount      :decimal(8, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class OnlineProduct < ActiveRecord::Base

  # Validations
  validates :name, :description, :amount, presence: true

  # Select options with all the online products
  def self.form_selector
    all.map{ |online_product| [online_product.name, online_product.id] }
  end
end
