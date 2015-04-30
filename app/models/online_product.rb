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
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class OnlineProduct < ActiveRecord::Base

  # Associations
  belongs_to :purchasable, polymorphic: true, touch: true

  # Validations
  validates :name, :description, :price, presence: true

end
