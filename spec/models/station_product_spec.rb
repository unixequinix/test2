# == Schema Information
#
# Table name: station_products
#
#  position   :integer
#  price      :float            not null
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
  subject { create(:station_product) }

  describe "station touch" do
    before(:each) { subject.save }

    it "resets the station updated_at field" do
      expect { subject.update!(price: 10) }.to change(subject.station, :updated_at)
    end
  end
end
