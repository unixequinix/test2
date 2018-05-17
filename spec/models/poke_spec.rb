require "rails_helper"

RSpec.describe Poke, type: :model do
  let(:event) { create(:event, state: "launched") }
  let(:station) { create(:station, event: event, category: 'top_up_refund') }
  let(:device) { create(:device) }
  let(:customer) { create(:customer, event: event) }
  let(:gtag) { create(:gtag, customer: customer, event: event) }
  let(:operator) { create(:customer, event: event, operator: true) }
  let(:operator_gtag) { create(:gtag, customer: operator, event: event) }
  let(:catalog_item) { create(:catalog_item, event: event) }
  let(:ticket_type) { create(:ticket_type, event: event) }
  let(:product) { create(:product, station: station) }

  before(:each) do
    @onsite_topups = create_list(:poke, 3, :as_topups, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag)
    @topups_credits = create_list(:poke, 3, :as_record_credit_topups, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag)
    @sales = create_list(:poke, 4, :as_sales, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag)
    @checkin = create(:poke, action: 'checkin', event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag, ticket_type: ticket_type, catalog_item: catalog_item)
    @access = create(:poke, action: 'checkpoint', event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag, ticket_type: ticket_type, catalog_item: catalog_item, access_direction: 1)
    @money_json = event.pokes.money_recon.as_json
    @credit_json = event.pokes.credit_flow.as_json
    @sales_simple_json = event.pokes.products_sale_simple(event.credits).as_json
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

      it "should have operator UID" do
        expect(@money_json.map { |i| i['operator_uid'] }.uniq).to eq(event.customers.where(operator: true).joins(:gtags).select(:tag_uid).pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(@money_json.map { |i| i['customer_uid'] }.uniq).to eq(event.customers.where(operator: false).joins(:gtags).select(:tag_uid).pluck(:tag_uid))
      end
    end

    context "should return credit flow" do
      it "should have correct credit values" do
        expect(@credit_json.map { |i| i['credit_amount'].to_f }.sum).to eq(event.pokes.map { |t| t.credit_amount.to_f }.sum)
      end

      it "should have correct fields" do
        expect(@credit_json.last.keys).to eq(%w[id action description customer_id payment_method credit_name credit_amount date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name num_operations])
      end

      it "should have operator UID" do
        expect(@credit_json.map { |i| i['operator_uid'] }.uniq).to eq(event.customers.where(operator: true).joins(:gtags).select(:tag_uid).pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(@credit_json.map { |i| i['customer_uid'] }.uniq).to eq(event.customers.where(operator: false).joins(:gtags).select(:tag_uid).pluck(:tag_uid))
      end
    end

    context "should return sale simple" do
      it "should have correct credit values" do
        expect(@sales_simple_json.map { |i| i['credit_amount'].to_f }.sum).to eq(event.pokes.where(action: 'sale').map(&:credit_amount).sum.to_f.abs)
      end

      it "simple sales should have correct fields" do
        expect(@sales_simple_json.last.keys).to eq(%w[id action description payment_method credit_name credit_amount date_time location station_type station_name])
      end
    end

    context "should return sale" do
      it "should have product names" do
        expect(@sales_json.map { |t| t["product_name"] }.sort).to eq(event.pokes.where(action: 'sale').map { |t| t.product.name }.sort)
      end

      it "should have correct credit values" do
        expect(@sales_json.map { |i| i['credit_amount'].to_f }.sum).to eq(event.pokes.where(action: 'sale').map(&:credit_amount).sum.to_f.abs)
      end

      it "product sales should have correct fields" do
        expect(@sales_json.last.keys).to eq(%w[id action description customer_id sale_item_quantity payment_method credit_name credit_amount date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name is_alcohol product_name num_operations])
      end

      it "products sale stock should have correct fields" do
        expect(event.pokes.products_sale_stock.as_json.last.keys).to eq(%w[id description operation_id sale_item_quantity operator_uid operator_name device_name location station_type station_name date_time product_name])
      end

      it "should have operator UID" do
        expect(@sales_json.map { |i| i['operator_uid'] }.uniq).to eq(event.customers.where(operator: true).joins(:gtags).select(:tag_uid).pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(@sales_json.map { |i| i['customer_uid'] }.uniq).to eq(event.customers.where(operator: false).joins(:gtags).select(:tag_uid).pluck(:tag_uid))
      end
    end

    context "should return checkin" do
      it "should have correct fields" do
        expect(@checkin_json.last.keys).to eq(%w[id action description customer_id ticket_type_id customer_uid customer_name operator_uid operator_name device_name location station_type station_name date_time catalog_item_name ticket_type_name total_tickets])
      end

      it "should have operator UID" do
        expect(@checkin_json.map { |i| i['operator_uid'] }.uniq).to eq(event.customers.where(operator: true).joins(:gtags).select(:tag_uid).pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(@checkin_json.map { |i| i['customer_uid'] }.uniq).to eq(event.customers.where(operator: false).joins(:gtags).select(:tag_uid).pluck(:tag_uid))
      end
    end

    context "should return access" do
      it "should return the correct sum for in-out accesses" do
        expect(event.pokes.access_in_out(catalog_item).as_json.map { |i| i['access_direction'] }.sum).to eq(event.pokes.where(action: 'checkpoint').map(&:access_direction).sum)
      end

      it "should return the correct sum for access capacity" do
        expect(event.pokes.access_capacity(catalog_item).as_json.map { |i| i['capacity'] }.sum).to eq(event.pokes.where(action: 'checkpoint').map(&:access_direction).sum)
      end

      it "should have correct fields" do
        expect(event.pokes.access.as_json.last.keys).to eq(%w[id access_direction date_time station_name zone direction direction_in direction_out capacity])
      end
    end
  end
end
