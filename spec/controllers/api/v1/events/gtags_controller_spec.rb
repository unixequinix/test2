require "rails_helper"

RSpec.describe Api::V1::Events::GtagsController, type: :controller do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  let(:db_gtags) { event.gtags }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }

  before do
    create(:gtag, event: event, customer: create(:customer, event: event))
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        db_gtags.each { |tag| tag.update!(customer: create(:customer, event: event)) }
        http_login(user.email, user.access_token)
      end

      it "returns a 200 status code" do
        get :index, params: params
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: params
        JSON.parse(response.body).map do |gtag|
          keys = %w[reference banned redeemed customer_id]
          expect(gtag.keys).to eq(keys)
        end
      end

      it "returns the correct data" do
        get :index, params: params
        JSON.parse(response.body).each do |list_gtag|
          gtag = db_gtags[db_gtags.index { |tag| tag.tag_uid == list_gtag["reference"] }]
          expect(list_gtag["reference"]).to eq(gtag.tag_uid)
          expect(list_gtag["banned"]).to eq(gtag.banned?)
          expect(list_gtag["customer_id"]).to eq(gtag.customer_id)
        end
      end

      context "with orders" do
        before(:each) do
          @customer = create(:customer, event: event, anonymous: false)
          @anon_customer = create(:customer, event: event, anonymous: true)
          create(:order, event: event, customer: @customer)
          create(:order, event: event, customer: @anon_customer)
        end

        it "returns gtags if they have a registered customer" do
          gtag = create :gtag, customer: @customer, event: event
          get :index, params: params
          gtags = JSON.parse(response.body).map(&:symbolize_keys)
          expect(gtags.find { |atts| atts[:reference].eql? gtag.tag_uid }).not_to be_nil
        end

        it "returns gtags if they have an anonymous customer" do
          gtag = create :gtag, customer: @anon_customer, event: event
          get :index, params: params
          gtags = JSON.parse(response.body).map(&:symbolize_keys)
          expect(gtags.find { |atts| atts[:reference].eql? gtag.tag_uid }).not_to be_nil
        end

        it "returns gtags if they are banned" do
          gtag = create :gtag, banned: true, event: event
          get :index, params: params
          gtags = JSON.parse(response.body).map(&:symbolize_keys)
          expect(gtags.find { |atts| atts[:reference].eql? gtag.tag_uid }).not_to be_nil
        end

        it "returns gtags if they have a ticket_type" do
          gtag = create :gtag, event: event, ticket_type: create(:ticket_type, event: event)
          get :index, params: params
          gtags = JSON.parse(response.body).map(&:symbolize_keys)
          expect(gtags.find { |atts| atts[:reference].eql? gtag.tag_uid }).not_to be_nil
        end

        it "does not return gtags without ticket_type, banned or customer" do
          gtag = create :gtag, event: event
          get :index, params: params
          gtags = JSON.parse(response.body).map(&:symbolize_keys)
          expect(gtags.find { |atts| atts[:reference].eql? gtag.tag_uid }).to be_nil
        end
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :index, params: params
        expect(response).to be_unauthorized
      end
    end
  end

  describe "GET show" do
    context "with authentication" do
      before do
        @pack = create(:pack, :with_access, event: event)
        @customer = create(:customer, event: event)
        @gtag = create(:gtag, event: event, customer: @customer)
        @gtag2 = create(:gtag, event: event, customer: @customer, active: false)
        @order = create(:order, customer: @customer, status: "completed", event: event)
        @item = create(:order_item, order: @order, catalog_item: @pack, counter: 1)

        http_login(user.email, user.access_token)
      end

      describe "when gtag exists" do
        before(:each) do
          get :show, params: params.merge(id: @gtag.tag_uid)
        end

        it "returns a 200 status code" do
          expect(response).to be_ok
        end

        it "returns the necessary keys" do
          gtag = JSON.parse(response.body)
          gtag_keys = %w[reference redeemed banned customer]
          customer_keys = %w[id first_name last_name email orders credentials]
          order_keys = %w[catalog_item_id amount status redeemed id]
          credential_keys = %w[reference type redeemed banned]

          expect(gtag.keys).to eq(gtag_keys)
          expect(gtag["customer"].keys).to eq(customer_keys)
          expect(gtag["customer"]["credentials"].map(&:keys).flatten.uniq).to eq(credential_keys)
          expect(gtag["customer"]["orders"].map(&:keys).flatten.uniq).to eq(order_keys)
        end

        it "returns the correct data" do
          customer = @gtag.customer

          gtag = {
            reference: @gtag.tag_uid,
            redeemed: @gtag.redeemed,
            banned: @gtag.banned,
            customer: {
              id:  @gtag.customer.id,
              credentials: [{ reference: @gtag.tag_uid, type: "gtag", banned: @gtag.banned, redeemed: @gtag.redeemed }],
              first_name: customer.first_name,
              last_name: customer.last_name,
              email: customer.email,
              orders: [{ catalog_item_id: @item.catalog_item_id,
                         amount: @item.amount,
                         status: @item.order.status,
                         redeemed: @item.redeemed,
                         id: @item.counter }]
            }
          }.as_json

          expect(JSON.parse(response.body)).to eq(gtag)
        end
      end

      describe "when gtag doesn't exist" do
        it "returns a 404 status code" do
          get :show, params: params.merge(id: Gtag.last.id + 10)
          expect(response.status).to eq(404)
        end
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :show, params: params.merge(id: Gtag.last.id)
        expect(response).to be_unauthorized
      end
    end
  end
end
