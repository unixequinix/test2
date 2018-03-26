require "rails_helper"

RSpec.describe Api::V1::Events::ParametersController, type: %i[controller api] do
  let(:user) { create(:user) }
  let(:event_serie) { create(:event_serie, :with_events) }
  let(:event) { create(:event, open_devices_api: true, gtag_type: "ultralight_c", gtag_key: "ab", event_serie_id: event_serie.id) }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, role: "glowball") }
  let(:device) { create(:device, team: team) }
  let(:device_token) { "#{device.app_id}+++#{device.serial}+++#{device.mac}+++#{device.imei}" }

  before do
    user.event_registrations.create!(email: "foo@bar.com", user: user, event: event)
    request.headers["HTTP_DEVICE_TOKEN"] = Base64.encode64(device_token)
    http_login(user.email, user.access_token)
  end

  describe "GET index" do
    describe "common parameters" do
      it "includes gtag_type" do
        test_inclusion("name" => "gtag_type", "value" => event.gtag_type)
      end

      it "includes uid_reverse" do
        test_inclusion("name" => "uid_reverse", "value" => event.uid_reverse)
      end

      it "includes sync_time_gtags" do
        test_inclusion("name" => "sync_time_gtags", "value" => event.sync_time_gtags)
      end

      it "includes sync_time_tickets" do
        test_inclusion("name" => "sync_time_tickets", "value" => event.sync_time_tickets)
      end

      it "includes transaction_buffer" do
        test_inclusion("name" => "transaction_buffer", "value" => event.transaction_buffer)
      end

      it "includes days_to_keep_backup" do
        test_inclusion("name" => "days_to_keep_backup", "value" => event.days_to_keep_backup)
      end

      it "includes sync_time_customers" do
        test_inclusion("name" => "sync_time_customers", "value" => event.sync_time_customers)
      end

      it "includes fast_removal_password" do
        test_inclusion("name" => "fast_removal_password", "value" => event.fast_removal_password)
      end

      it "includes private_zone_password" do
        test_inclusion("name" => "private_zone_password", "value" => event.private_zone_password)
      end

      it "includes sync_time_server_date" do
        test_inclusion("name" => "sync_time_server_date", "value" => event.sync_time_server_date)
      end

      it "includes stations_apply_orders" do
        test_inclusion("name" => "stations_apply_orders", "value" => event.stations_apply_orders)
      end

      it "includes stations_initialize_gtags" do
        test_inclusion("name" => "stations_initialize_gtags", "value" => event.stations_initialize_gtags)
      end

      it "includes sync_time_basic_download" do
        test_inclusion("name" => "sync_time_basic_download", "value" => event.sync_time_basic_download)
      end

      it "includes sync_time_event_parameters" do
        test_inclusion("name" => "sync_time_event_parameters", "value" => event.sync_time_event_parameters)
      end

      it "includes maximum_gtag_balance" do
        test_inclusion("name" => "maximum_gtag_balance", "value" => event.maximum_gtag_balance)
      end

      it "includes old_event_keys" do
        test_inclusion("name" => "old_event_keys", "value" => "11111111111111111111111111111111")
      end

      it "includes stations_apply_tickets" do
        test_inclusion("name" => "stations_apply_tickets", "value" => false)
      end
    end

    describe "fees" do
      it "includes gtag_deposit_fee if present" do
        event.update! gtag_deposit_fee: 5
        test_inclusion("name" => "gtag_deposit_fee", "value" => event.gtag_deposit_fee)
      end

      it "does not include gtag_deposit_fee if nil" do
        event.update! gtag_deposit_fee: nil
        test_absence("name" => "gtag_deposit_fee", "value" => nil)
      end

      it "includes every_topup_fee if present" do
        event.update! every_topup_fee: 5
        test_inclusion("name" => "topup_fee", "value" => event.every_topup_fee)
      end

      it "does not include every_topup_fee if nil" do
        event.update! every_topup_fee: nil
        test_absence("name" => "topup_fee", "value" => nil)
      end

      it "includes onsite_initial_topup_fee if present as initial_topup_fee" do
        event.update! onsite_initial_topup_fee: 5
        test_inclusion("name" => "initial_topup_fee", "value" => event.onsite_initial_topup_fee)
      end

      it "does not include onsite_initial_topup_fee if nil" do
        event.update! onsite_initial_topup_fee: nil
        test_absence("name" => "initial_topup_fee", "value" => nil)
      end
    end

    describe "gtag_type" do
      before do
        http_login(user.email, user.access_token)
      end

      it "should include gtag_key" do
        get :index, params: params
        @body = JSON.parse(response.body)
        test_inclusion("name" => "gtag_key", "value" => "11111111111111111111111111111111")
      end
    end

    def test_inclusion(value)
      get :index, params: params
      expect(JSON.parse(response.body)).to include(value)
    end

    def test_absence(value)
      get :index, params: params
      expect(JSON.parse(response.body)).not_to include(value)
    end
  end
end
