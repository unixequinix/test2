# == Schema Information
#
# Table name: catalog_items
#
#  id               :integer          not null, primary key
#  event_id         :integer          not null
#  catalogable_id   :integer          not null
#  catalogable_type :string           not null
#  name             :string
#  description      :text
#  initial_amount   :integer
#  step             :integer
#  max_purchasable  :integer
#  min_purchasable  :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CatalogItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :event
  belongs_to :catalogable, polymorphic: true, touch: true


  validates :name, :initial_amount, :step, :max_purchasable, :min_purchasable, presence: true
end
