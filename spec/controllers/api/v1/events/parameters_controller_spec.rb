require "rails_helper"

RSpec.describe Api::V1::Events::ParametersController, type: :controller do
  let(:user) { create(:user) }
  let(:event_serie) { create(:event_serie, :with_events) }
  let(:event) { create(:event, open_devices_api: true, gtag_type: "ultralight_c", gtag_key: "ab", event_serie_id: event_serie.id) }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }

  describe "GET index" do
    describe "common parameters" do
      before do
        http_login(user.email, user.access_token)
        get :index, params: params
        @body = JSON.parse(response.body)
      end

      it "includes gtag_type" do
        expect(@body).to include("name" => "gtag_type", "value" => event.gtag_type)
      end

      it "includes uid_reverse" do
        expect(@body).to include("name" => "uid_reverse", "value" => event.uid_reverse)
      end

      it "includes sync_time_gtags" do
        expect(@body).to include("name" => "sync_time_gtags", "value" => event.sync_time_gtags)
      end

      it "includes sync_time_tickets" do
        expect(@body).to include("name" => "sync_time_tickets", "value" => event.sync_time_tickets)
      end

      it "includes transaction_buffer" do
        expect(@body).to include("name" => "transaction_buffer", "value" => event.transaction_buffer)
      end

      it "includes days_to_keep_backup" do
        expect(@body).to include("name" => "days_to_keep_backup", "value" => event.days_to_keep_backup)
      end

      it "includes sync_time_customers" do
        expect(@body).to include("name" => "sync_time_customers", "value" => event.sync_time_customers)
      end

      it "includes fast_removal_password" do
        expect(@body).to include("name" => "fast_removal_password", "value" => event.fast_removal_password)
      end

      it "includes private_zone_password" do
        expect(@body).to include("name" => "private_zone_password", "value" => event.private_zone_password)
      end

      it "includes sync_time_server_date" do
        expect(@body).to include("name" => "sync_time_server_date", "value" => event.sync_time_server_date)
      end

      it "includes stations_apply_orders" do
        expect(@body).to include("name" => "stations_apply_orders", "value" => event.stations_apply_orders)
      end

      it "includes stations_initialize_gtags" do
        expect(@body).to include("name" => "stations_initialize_gtags", "value" => event.stations_initialize_gtags)
      end

      it "includes sync_time_basic_download" do
        expect(@body).to include("name" => "sync_time_basic_download", "value" => event.sync_time_basic_download)
      end

      it "includes sync_time_event_parameters" do
        expect(@body).to include("name" => "sync_time_event_parameters", "value" => event.sync_time_event_parameters)
      end

      it "includes gtag_deposit" do
        expect(@body).to include("name" => "gtag_deposit_fee", "value" => event.gtag_deposit_fee)
      end

      it "includes topup_fee" do
        expect(@body).to include("name" => "gtag_deposit_fee", "value" => event.topup_fee)
      end

      it "includes initial_topup_fee" do
        expect(@body).to include("name" => "initial_topup_fee", "value" => event.initial_topup_fee)
      end

      it "includes maximum_gtag_balance" do
        expect(@body).to include("name" => "maximum_gtag_balance", "value" => event.maximum_gtag_balance)
      end

      it "includes old_event_keys" do
        expect(@body).to include("name" => "old_event_keys", "value" => "11111111111111111111111111111111")
      end

      it "includes stations_apply_tickets" do
        expect(@body).to include("name" => "stations_apply_tickets", "value" => false)
      end
    end

    describe "gtag_type" do
      before do
        http_login(user.email, user.access_token)
      end

      it "should include gtag_key" do
        get :index, params: params
        @body = JSON.parse(response.body)
        expect(@body).to include("name" => "gtag_key", "value" => "11111111111111111111111111111111")
      end
    end
  end
end
