class CatalogItemPack < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :pack
  belongs_to :catalog_item

  validates :amount, presence: true
end
