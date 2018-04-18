require "rails_helper"

RSpec.describe Poke, type: :model do
  let(:event) { create(:event, state: "launched") }
  let(:station) { create(:station, event: event, category: 'top_up_refund') }
  let(:device) { create(:device) }
  let(:customer) { create(:customer, event: event) }
  let(:gtag) { create(:gtag, customer: customer, event: event) }
  let(:catalog_item) { create(:catalog_item, event: event) }
  let(:ticket_type) { create(:ticket_type, event: event) }
  let(:product) { create(:product) }

  before(:each) do
    @onsite_topups = create_list(:poke, 3, :as_topups, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: customer, operator_gtag: gtag)
    @topups_credits = create_list(:poke, 3, :as_record_credit_topups, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: customer, operator_gtag: gtag)
    @sales = create_list(:poke, 3, :as_sales, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: customer, operator_gtag: gtag)
    @checkin = create(:poke, action: 'checkin', event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: customer, operator_gtag: gtag, ticket_type: ticket_type, catalog_item: catalog_item)
    @money_json = event.pokes.money_recon.as_json
    @credit_json = event.pokes.credit_flow.as_json
    @sales_json = event.pokes.products_sale(event.credits).as_json
    @checkin_json = event.pokes.checkin_ticket_type.as_json
  end

  describe "check json returned value" do
    context "should return money recon" do
      it "should have correct money values" do
        expect(@money_json.map { |i| i['money'].to_f }.sum).to eq(@onsite_topups.map(&:monetary_total_price).sum.to_f)
      end

      it "should have correct fields" do
        expect(@money_json.last.keys).to eq(%w[id action description source customer_id payment_method date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name money num_operations])
      end
    end

    context "should return credit flow" do
      it "should have correct credit values" do
        expect(@credit_json.map { |i| i['credit_amount'].to_f }.sum).to eq(event.pokes.map { |t| t.credit_amount.to_f }.sum)
      end

      it "should have correct fields" do
        expect(@credit_json.last.keys).to eq(%w[id action description customer_id payment_method credit_name credit_amount date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name num_operations])
      end
    end

    context "should return sale" do
      it "should have correct credit values" do
        expect(@sales_json.map { |i| i['credit_amount'].to_f }.sum).to eq(event.pokes.where(action: 'sale').map(&:credit_amount).sum.to_f.abs)
      end

      it "should have correct fields" do
        expect(@sales_json.last.keys).to eq(%w[id action description customer_id sale_item_quantity payment_method credit_name credit_amount date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name is_alcohol product_name num_operations])
      end
    end

    context "should return checkin" do
      it "should have correct fields" do
        expect(@checkin_json.last.keys).to eq(%w[id action description customer_id ticket_type_id customer_uid customer_name operator_uid operator_name device_name location station_type station_name date_time catalog_item_name ticket_type_name total_tickets])
      end
    end
  end
end
