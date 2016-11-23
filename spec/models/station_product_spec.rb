# == Schema Information
#
# Table name: station_products
#
#  created_at :datetime         not null
#  position   :integer
#  price      :float            not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_station_products_on_product_id  (product_id)
#  index_station_products_on_station_id  (station_id)
#
# Foreign Keys
#
#  fk_rails_b1a69cdc0c  (product_id => products.id)
#  fk_rails_d96ed1200f  (station_id => stations.id)
#

require "spec_helper"

RSpec.describe StationProduct, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
