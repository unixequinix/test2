require "rails_helper"

RSpec.describe Poke, type: :model do
  let(:event) { create(:event, state: "launched") }

  before(:each) do
    @onsite_topups = create_list(:poke, 3, :as_topups, event: event)
    @sales = create_list(:poke, 3, :as_sales, event: event)
    @checkin = create(:poke, action: 'checkin', event: event)
    @money_json = event.pokes.money_recon.as_json
    @sales_json = event.pokes.products_sale(event.credits.pluck(:id)).as_json
    @checkin_json = event.pokes.checkin_ticket_type.as_json
  end

  describe "check json returned value" do
    before(:each) do
      create(:station, category: 'top_up_refund')
    end

    context "should return money recon" do
      it "should have correct money values" do
        expect(@money_json.map { |i| i['money'].to_f }.sum).to eq(@onsite_topups.map(&:monetary_total_price).sum.to_f)
      end

      it "should have correct fields" do
        expect(@money_json.last.keys).to eq(%w[id action description source customer_id payment_method date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name money])
      end
    end

    context "should return sale" do
      it "should have correct money values" do
        expect(@sales_json.map { |i| i['credit_amount'].to_f }.sum).to eq(@sales.map(&:credit_amount).sum.to_f.abs)
      end

      it "should have correct fields" do
        expect(@sales_json.last.keys).to eq(%w[id action description customer_id payment_method credit_name credit_amount date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name is_alcohol product_name])
      end
    end

    context "should return checkin" do
      it "should have correct fields" do
        expect(@checkin_json.last.keys).to eq(%w[id action description customer_id ticket_type_id monetary_total_price customer_uid customer_name operator_uid operator_name device_name location station_type station_name date_time catalog_item_name ticket_type_name total_tickets])
      end
    end
  end
end
