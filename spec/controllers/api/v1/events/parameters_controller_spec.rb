require "spec_helper"

RSpec.describe Api::V1::Events::ParametersController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event, gtag_type: "ultralight_c", ultralight_c_private_key: "ab") }

  describe "GET index" do
    describe "common parameters" do
      before do
        http_login(user.email, user.access_token)
        get :index, params: { event_id: event.id }
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

      it "includes topup_initialize_gtag" do
        expect(@body).to include("name" => "topup_initialize_gtag", "value" => event.topup_initialize_gtag)
      end

      it "includes pos_update_online_orders" do
        expect(@body).to include("name" => "pos_update_online_orders", "value" => event.pos_update_online_orders)
      end

      it "includes sync_time_basic_download" do
        expect(@body).to include("name" => "sync_time_basic_download", "value" => event.sync_time_basic_download)
      end

      it "includes sync_time_event_parameters" do
        expect(@body).to include("name" => "sync_time_event_parameters", "value" => event.sync_time_event_parameters)
      end

      it "includes touchpoint_update_online_orders" do
        expect(@body).to include("name" => "touchpoint_update_online_orders", "value" => event.touchpoint_update_online_orders)
      end

      it "includes gtag_format" do
        expect(@body).to include("name" => "gtag_format", "value" => event.gtag_format)
      end

      it "includes gtag_deposit" do
        expect(@body).to include("name" => "gtag_deposit", "value" => event.gtag_deposit)
      end

      it "includes cards_can_refund" do
        expect(@body).to include("name" => "cards_can_refund", "value" => event.cards_can_refund)
      end

      it "includes maximum_gtag_balance" do
        expect(@body).to include("name" => "maximum_gtag_balance", "value" => event.maximum_gtag_balance)
      end

      it "includes wristbands_can_refu" do
        expect(@body).to include("name" => "wristbands_can_refund", "value" => event.wristbands_can_refund)
      end
    end

    describe "gtag_type" do
      before do
        http_login(user.email, user.access_token)
      end

      it "should include ultralight_c_private_key if gtag_type is ultralight_c" do
        get :index, params: { event_id: event.id }
        @body = JSON.parse(response.body)
        expect(@body).to include("name" => "ultralight_c_private_key", "value" => event.ultralight_c_private_key)
      end

      it "should include all mifare keys if gtag_type is mifare_classic" do
        event.update!(gtag_type: "mifare_classic")
        get :index, params: { event_id: event.id }
        @body = JSON.parse(response.body)
        expect(@body).to include("name" => "mifare_classic_private_key_a", "value" => event.mifare_classic_private_key_a)
        expect(@body).to include("name" => "mifare_classic_private_key_b", "value" => event.mifare_classic_private_key_b)
        expect(@body).to include("name" => "mifare_classic_public_key", "value" => event.mifare_classic_public_key)
      end
    end
  end
end
