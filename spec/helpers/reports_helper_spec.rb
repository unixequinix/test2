require "rails_helper"
require "json_expressions/rspec"

# rubocop:disable all

RSpec.describe ReportsHelper, type: :helper do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:stat0) { create(:stat, event: event, action: "refund", date: Time.current, station_name: "station1", monetary_total_price: -10.00) }
  let(:stat1) { create(:stat, event: event, action: "topup", date: Time.current, station_name: "station1", monetary_total_price: 10.00) }
  let(:stat2) { create(:stat, event: event, action: "topup", date: Time.current, station_name: "station1", monetary_total_price: 10.00) }
  let(:stat3) { create(:stat, event: event, action: "puchase", date: Time.current, station_name: "station_3", monetary_total_price: 10.00) }
  let(:stat4) { create(:stat, event: event, action: "puchase", date: Time.current, station_name: "station_3", monetary_total_price: 10.00) }
  let(:stat5) { create(:stat, event: event, action: "topup", date: Time.current, station_name: "station2", monetary_total_price: 10.00) }

  # let(:stat5) { create(:stat, event: event, action: "refund", date: Time.current, station_name:"station_3",monetary_total_price: 10.00) }
  # let(:stat6) { create(:stat, event: event, action: "puchase", date: Time.current, station_name:"station_3",monetary_total_price: 10.00) }

  def event_date(date)
    date - 8.hours
  end

  describe "GET result from querys" do
    context "with autentication and test stats" do
      # it "query 1 deberia de funcionar" do
      #  json = [{ "event_day"=> event_date(stat0.date).strftime("%d-%m-%Y"), "station_name"=>stat0.station_name, "monetary_total_price"=> '%.2f' % stat0.monetary_total_price }]
      #  expect(helper.data_connection(helper.query_test(event.id))).to eql(json)
      # end

      it "query_action_station_money_should return_expected_result" do
        json = [{ "action" => stat0.action, "station_name" => stat0.station_name, "event_day" => event_date(stat0.date).strftime("%d-%m-%Y"), "money" => format('%.2f', stat0.monetary_total_price) },
                { "action" => stat1.action, "station_name" => stat1.station_name, "event_day" => event_date(stat1.date).strftime("%d-%m-%Y"), "money" => format('%.2f', (stat1.monetary_total_price + stat2.monetary_total_price)) },
                { "action" => stat3.action, "station_name" => stat3.station_name, "event_day" => event_date(stat3.date).strftime("%d-%m-%Y"), "money" => format('%.2f', (stat3.monetary_total_price + stat4.monetary_total_price)) },
                { "action" => stat5.action, "station_name" => stat5.station_name, "event_day" => event_date(stat5.date).strftime("%d-%m-%Y"), "money" => format('%.2f', stat5.monetary_total_price) }]
        expect(helper.data_connection(helper.query_action_station_money(event.id))).to match_json_expression(json)
      end
    end
  end
  query_methods = %w[query_action_station_money query_operator_recon query_activations query_devices query_leftover_balance query_credit_flow query_topup_refund query_sales_by_station_device
                     query_sales_by_station query_top_products_by_quantity query_top_products_by_amount query_performance_by_station query_products_sale_station query_tickets_checkedin
                     query_checkedin_by_station query_accreditation query_access_ctrl_station query_access_ctrl_min query_products_sale_overall query_operators_sale query_operators_money]

  context "Validate Queries" do
    query_methods.each do |query_name|
      it "#{query_name} should return a string" do
        expect(helper.method(query_name).call(event.id).class).to eql(String)
      end

      it "#{query_name} should contain event_id = event.id" do
        expect(helper.method(query_name).call(event.id)).to include(event.id.to_s)
      end
    end
  end
end
