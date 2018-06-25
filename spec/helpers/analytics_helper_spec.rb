require "rails_helper"

RSpec.describe AnalyticsHelper, type: :helper do
  let(:event) { create(:event, state: "launched") }
  let(:station) { create(:station, event: event, category: 'top_up_refund') }
  let(:device) { create(:device) }
  let(:customer) { create(:customer, event: event) }
  let(:gtag) { create(:gtag, customer: customer, event: event) }
  let(:operator) { create(:customer, event: event, operator: true) }
  let(:operator_gtag) { create(:gtag, customer: operator, event: event) }
  let(:catalog_item) { create(:catalog_item, event: event, type: 'Access') }
  let(:ticket_type) { create(:ticket_type, event: event, catalog_item: catalog_item) }
  let(:product) { create(:product, station: station) }

  before(:each) do
    @onsite_topups = create_list(:poke, 3, :as_topups, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag)
    @topups_credits = create_list(:poke, 3, :as_record_credit_topups, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag)
    @credit_sales = create_list(:poke, 4, :as_sales, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag, credit: event.credit)
    @virtual_credit_sales = create_list(:poke, 4, :as_sales, event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag, credit: event.virtual_credit)
    create(:poke, action: 'checkin', event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag, ticket_type: ticket_type, catalog_item: catalog_item)
    create(:poke, action: 'checkpoint', event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag, catalog_item: catalog_item, access_direction: 1)
    create(:poke, action: 'exhibitor_note', event: event, station: station, device: device, customer: customer, customer_gtag: gtag, operator: operator, operator_gtag: operator_gtag, message: 'holi', priority: 3)
    create_list(:poke, 4, :as_access, event: event, station: station, catalog_item: catalog_item, customer: customer)
    create(:ticket, event: event, ticket_type: ticket_type, customer: customer, redeemed: true)

    @customers = create_list(:customer, 3, event: event, anonymous: false)
    @customers.each do |customer|
      gtag = create(:gtag, event: event, customer: customer, credits: rand(10..50))
      customer.reload
      create(:refund, event: event, customer: customer, credit_base: gtag.credits - 2, credit_fee: 2, status: 2)
      create(:refund, event: event, customer: customer, credit_base: gtag.credits - 2, credit_fee: 2, status: 1)
    end
  end

  describe "test for analytics helper used in standard and custom reports" do
    before(:each) { @current_event = event }

    context "should return money" do
      it "should have correct money values" do
        money = @onsite_topups.map(&:monetary_total_price).sum - event.refunds.completed.map(&:credit_base).sum * event.credit.value
        expect(pokes_money.map { |i| i['money'].to_f }.sum).to eq(money.to_f)
      end

      it "should have correct fields" do
        expect(pokes_money.first.keys).to match_array(%w[id action description source customer_id payment_method date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name money num_operations event_day])
      end

      it "should have operator UID" do
        expect(pokes_money.map { |i| i['operator_uid'] }.uniq.compact).to eq(operator.gtags.pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(pokes_money.map { |i| i['customer_uid'] }.uniq.compact).to eq(customer.gtags.pluck(:tag_uid))
      end
    end

    context "should return money simplified" do
      it "should have correct money values" do
        money = @onsite_topups.map(&:monetary_total_price).sum - event.refunds.completed.map(&:credit_base).sum * event.credit.value
        expect(pokes_money_simple.map { |i| i['money'].to_f }.sum).to eq(money.to_f)
      end

      it "should have correct fields" do
        expect(pokes_money_simple.last.keys).to eq(%w[id customer_id action description source operator_uid operator_name device_name location station_type station_name event_day date_time payment_method num_operations money])
      end

      it "should have operator UID" do
        expect(pokes_money_simple.map { |i| i['operator_uid'] }.uniq.compact).to eq(operator.gtags.pluck(:tag_uid))
      end
    end

    context "should return credit flow" do
      it "should have correct credit values" do
        credits = @topups_credits.map(&:credit_amount).sum + @credit_sales.map(&:credit_amount).sum + @virtual_credit_sales.map(&:credit_amount).sum - event.refunds.completed.map(&:credit_fee).sum - event.refunds.completed.map(&:credit_base).sum
        expect(pokes_credits.map { |i| i['credit_amount'].to_f }.sum).to eq(credits.to_f)
      end

      it "should have correct fields" do
        expect(pokes_credits.first.keys).to eq(%w[id action description customer_id payment_method credit_name credit_amount date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name num_operations event_day])
      end

      it "should have operator UID" do
        expect(pokes_credits.map { |i| i['operator_uid'] }.uniq.compact).to eq(operator.gtags.pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(pokes_credits.map { |i| i['customer_uid'] }.uniq.compact).to eq(customer.gtags.pluck(:tag_uid))
      end
    end

    context "should return sale simple" do
      it "should have correct credit values" do
        expect(pokes_sales_simple.map { |i| i['credit_amount'].to_f }.sum).to eq((@credit_sales.map(&:credit_amount).sum + @virtual_credit_sales.map(&:credit_amount).sum).to_f.abs)
      end

      it "simple sales should have correct fields" do
        expect(pokes_sales_simple.first.keys).to eq(%w[id action description payment_method credit_name credit_amount operator_uid operator_name device_name date_time location station_type station_name is_alcohol product_name event_day])
      end

      it "should have product" do
        comun_products = @current_event.stations.map { |t| t.products.pluck(:name) }.flatten & pokes_sales.map { |i| i['product_name'] }.uniq.compact
        expect(pokes_sales_simple.map { |i| i['product_name'] }.uniq.compact.sort).to eq(comun_products.sort)
      end

      it "should have operator UID" do
        expect(pokes_sales_simple.map { |i| i['operator_uid'] }.uniq.compact).to eq(operator.gtags.pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(pokes_sales_simple.map { |i| i['customer_uid'] }.uniq.compact).to eq([])
      end
    end

    context "should return sale" do
      it "should have correct credit values" do
        expect(pokes_sales.map { |i| i['credit_amount'].to_f }.sum).to eq((@credit_sales.map(&:credit_amount).sum + @virtual_credit_sales.map(&:credit_amount).sum).to_f.abs)
      end

      it "product sales should have correct fields" do
        expect(pokes_sales.last.keys).to eq(%w[id action description customer_id sale_item_quantity payment_method credit_name credit_amount date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name is_alcohol product_name num_operations event_day])
      end

      it "should have product" do
        comun_products = @current_event.stations.map { |t| t.products.pluck(:name) }.flatten & pokes_sales.map { |i| i['product_name'] }.uniq.compact
        expect(pokes_sales.map { |i| i['product_name'] }.uniq.compact.sort).to eq(comun_products.sort)
      end

      it "should have operator UID" do
        expect(pokes_sales.map { |i| i['operator_uid'] }.uniq.compact).to eq(operator.gtags.pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(pokes_sales.map { |i| i['customer_uid'] }.uniq.compact).to eq(customer.gtags.pluck(:tag_uid))
      end
    end

    context "should return checkin" do
      it "should have correct fields" do
        expect(pokes_checkin.last.keys).to eq(%w[id action description customer_id ticket_type_id customer_uid customer_name operator_uid operator_name device_name location station_type station_name date_time catalog_item_name ticket_type_name total_tickets event_day code])
      end

      it "should have operator UID" do
        expect(pokes_checkin.map { |i| i['operator_uid'] }.uniq).to eq(operator.gtags.pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(pokes_checkin.map { |i| i['customer_uid'] }.uniq).to eq(customer.gtags.pluck(:tag_uid))
      end

      it "should have Ticket Type" do
        expect(pokes_checkin.map { |i| i['ticket_type_name'] }.uniq).to eq(event.ticket_types.pluck(:name))
      end

      it "should have Ticket Code" do
        expect(pokes_checkin.map { |i| i['code'] }.uniq).to eq(event.tickets.redeemed.pluck(:code))
      end
    end

    context "should return access" do
      it "should return the correct sum for in-out accesses" do
        expect(pokes_access_in_out(catalog_item).map { |i| i['access_direction'].to_f }.sum).to eq(event.pokes.where(action: 'checkpoint').map(&:access_direction).sum.to_f)
      end

      it "should return the correct sum for access capacity" do
        expect(pokes_access_capacity(catalog_item).map { |i| i['capacity'].to_f }.sum).to eq(event.pokes.where(action: 'checkpoint').map(&:access_direction).sum.to_f)
      end

      it "should return one access by customer" do
        expect(pokes_access_by_ticket_type(catalog_item).length).to eq(event.pokes.where(action: 'checkpoint').distinct.count(:customer_id))
      end

      it "access should have correct fields" do
        expect(pokes_access.last.keys).to eq(%w[id access_direction date_time zone direction direction_in direction_out capacity event_day])
      end
    end

    context "should return exhibitor notes" do
      it "should return the correct sum for in-out accesses" do
        expect(pokes_engagement.map { |i| i['message'] }).to eq(event.pokes.where(action: 'exhibitor_note').map(&:message))
      end

      it "should return the correct sum for in-out accesses" do
        expect(pokes_engagement.map { |i| i['priority'].to_f }.sum).to eq(event.pokes.where(action: 'exhibitor_note').map(&:priority).sum.to_f)
      end

      it "should have operator UID" do
        expect(pokes_engagement.map { |i| i['operator_uid'] }.uniq.compact).to eq(operator.gtags.pluck(:tag_uid))
      end

      it "should have customer UID" do
        expect(pokes_engagement.map { |i| i['customer_uid'] }.uniq.compact).to eq(customer.gtags.pluck(:tag_uid))
      end

      it "access should have correct fields" do
        expect(pokes_engagement.last.keys).to eq(%w[id customer_id message priority date_time customer_uid customer_name operator_uid operator_name device_name location station_type station_name num_operations event_day])
      end
    end
  end
end
