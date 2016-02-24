class CatalogItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :event
  belongs_to :catalogable, polymorphic: true, touch: true


  validates :name, :initial_amount, :step, :max_purchasable, :min_purchasable, presence: true
end
