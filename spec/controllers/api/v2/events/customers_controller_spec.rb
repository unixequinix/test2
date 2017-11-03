
require 'rails_helper'

RSpec.describe Api::V2::Events::CustomersController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:customer) { create(:customer, event: event) }

  let(:atts) { { id: customer.to_param, event_id: event.to_param } }
  let(:invalid_attributes) { { email: "aaa" } }
  let(:valid_attributes) { { first_name: "test customer", last_name: "foo", email: "foo@bar.com", password: "password" } }

  before { token_login(user, event) }

  describe "POST #gtag_replacement" do
    let(:new_gtag) { create(:gtag, tag_uid: "12345678", event: event) }
    let(:new_atts) { atts.merge(new_tag_uid: new_gtag.tag_uid) }

    before { create(:gtag, tag_uid: "AAAAAAAA", event: event, customer: customer, active: true) }

    it "replaces the active gtag for the given customer" do
      expect { post :gtag_replacement, params: new_atts }.to change { customer.reload.active_gtag.tag_uid }.from("AAAAAAAA").to(new_gtag.tag_uid)
    end

    it "returns unprocessable_entity if new_tag_uid does not match any gtags" do
      new_atts[:new_tag_uid] = "INVALIDTAG"
      post :gtag_replacement, params: new_atts
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns unprocessable_entity if customer has no gtag" do
      customer.update! active_gtag: nil
      post :gtag_replacement, params: new_atts
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a success response" do
      post :gtag_replacement, params: new_atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer as JSON" do
      post :gtag_replacement, params: new_atts
      expect(json).to eq(obj_to_json(customer, "Full::CustomerSerializer"))
    end
  end

  describe "POST #ban" do
    it "returns a success response" do
      post :ban, params: atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer as JSON" do
      post :ban, params: atts
      expect(json).to eq(obj_to_json(customer, "Full::CustomerSerializer"))
    end

    it "bans all the gtags" do
      gtag = create(:gtag, tag_uid: "AAAAAAAA", event: event, customer: customer, active: true)
      expect { post(:ban, params: atts) }.to change { gtag.reload.banned }.from(false).to(true)
    end

    it "bans all the tickets" do
      ticket = create(:ticket, code: "AAAAAAAA", event: event, customer: customer)
      expect { post(:ban, params: atts) }.to change { ticket.reload.banned }.from(false).to(true)
    end
  end

  describe "POST #unban" do
    it "returns a success response" do
      post :unban, params: atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer as JSON" do
      post :unban, params: atts
      expect(json).to eq(obj_to_json(customer, "Full::CustomerSerializer"))
    end

    it "bans all the gtags" do
      gtag = create(:gtag, tag_uid: "AAAAAAAA", event: event, customer: customer, active: true, banned: true)
      expect { post(:unban, params: atts) }.to change { gtag.reload.banned }.from(true).to(false)
    end

    it "bans all the tickets" do
      ticket = create(:ticket, code: "AAAAAAAA", event: event, customer: customer, banned: true)
      expect { post(:unban, params: atts) }.to change { ticket.reload.banned }.from(true).to(false)
    end
  end

  describe "POST #assign_gtag" do
    let(:new_gtag) { create(:gtag, tag_uid: "12345678", event: event) }
    let(:new_atts) { atts.merge(tag_uid: new_gtag.tag_uid) }

    it "returns a success response" do
      post :assign_gtag, params: new_atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer as JSON" do
      post :assign_gtag, params: new_atts
      expect(json).to eq(obj_to_json(customer, "Full::CustomerSerializer"))
    end

    it "assigns the gtag to the customer" do
      expect { post :assign_gtag, params: new_atts }.to change { new_gtag.reload.customer }.from(nil).to(customer)
    end

    it "makes the new gtag active by default" do
      new_gtag.update! active: false
      expect { post :assign_gtag, params: new_atts }.to change { customer.reload.active_gtag }.from(nil).to(new_gtag)
    end

    it "does not make active if specified" do
      new_atts[:active] = false
      new_gtag.update! active: false
      expect { post :assign_gtag, params: new_atts }.not_to change { customer.reload.active_gtag } # rubocop:disable Lint/AmbiguousBlockAssociation
    end

    it "returns unprocessable_entity if tag_uid does not match any gtags" do
      new_atts[:tag_uid] = "INVALIDTAG"
      post :assign_gtag, params: new_atts
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST #assign_ticket" do
    let(:new_ticket) { create(:ticket, code: "AAAAAAAA", event: event) }
    let(:new_atts) { atts.merge(code: new_ticket.code) }

    it "returns a success response" do
      post :assign_ticket, params: new_atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer as JSON" do
      post :assign_ticket, params: new_atts
      expect(json).to eq(obj_to_json(customer, "Full::CustomerSerializer"))
    end

    it "assigns the ticket to the customer" do
      expect { post :assign_ticket, params: new_atts }.to change { new_ticket.reload.customer }.from(nil).to(customer)
    end

    it "returns unprocessable_entity if tag_uid does not match any tickets" do
      new_atts[:code] = "INVALIDTAG"
      post :assign_ticket, params: new_atts
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST #topup" do
    let(:new_atts) { atts.merge(credits: 100, gateway: "paypal") }

    before do
      station = create :station, name: "Customer Portal", category: "customer_portal", event: event
      station.station_catalog_items.create! catalog_item: event.credit, price: 10
    end

    it "returns a success response" do
      post :topup, params: new_atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer as JSON" do
      post :topup, params: new_atts
      expect(json).to eq(obj_to_json(customer.reload.orders.last, "OrderSerializer"))
    end

    it "creates an order for the customer" do
      expect { post :topup, params: new_atts }.to change { customer.reload.orders.count }.by(1)
    end

    it "sums to the credit of the customer" do
      expect { post :topup, params: new_atts }.to change { customer.global_credits }.by(100)
    end

    it "return unprocessable entity if credits are not present" do
      new_atts[:credits] = nil
      post :topup, params: new_atts
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "return unprocessable entity if credits are negative" do
      new_atts[:credits] = -10
      post :topup, params: new_atts
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "sets the new orders gateway accordingly" do
      new_atts[:gateway] = "somethingcrazy"
      post :topup, params: new_atts
      expect(customer.reload.orders.last.gateway).to eq("somethingcrazy")
    end
  end

  describe "POST #virtual_topup" do
    let(:new_atts) { atts.merge(credits: 10, gateway: "paypal") }

    before do
      station = create :station, name: "Customer Portal", category: "customer_portal", event: event
      station.station_catalog_items.create! catalog_item: event.credit, price: 1
    end

    it "returns a success response" do
      post :virtual_topup, params: new_atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer orders as JSON" do
      post :virtual_topup, params: new_atts
      expect(json).to eq(obj_to_json(customer.reload.orders.last, "OrderSerializer"))
    end

    it "creates an order for the customer" do
      expect { post :virtual_topup, params: new_atts }.to change { customer.reload.orders.count }.by(1)
    end

    it "sums to the global credits of the customer" do
      expect { post :virtual_topup, params: new_atts }.to change { customer.global_credits }.by(10.0)
    end

    it "sums to the global refundable credits of the customer" do
      expect { post :virtual_topup, params: new_atts }.to change { customer.global_refundable_credits }.by(0.0)
    end

    it "return unprocessable entity if credits are not present" do
      new_atts[:credits] = nil
      post :virtual_topup, params: new_atts
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "return unprocessable entity if credits are negative" do
      new_atts[:credits] = -10
      post :virtual_topup, params: new_atts
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "sets the new orders gateway accordingly" do
      new_atts[:gateway] = "somethingcrazy"
      post :virtual_topup, params: new_atts
      expect(customer.reload.orders.last.gateway).to eq("somethingcrazy")
    end

    it "should create a pack" do
      expect { post :virtual_topup, params: new_atts }.to change { customer.event.packs.count }.by(1)
    end

    it "should find a created pack" do
      pack = create(:pack, :with_credit, event: event)
      expect { post :virtual_topup, params: new_atts.merge(name: pack.name) }.to change { customer.event.packs.count }.by(0)
    end

    it "pack should have a credit catalog item with value 1" do
      pack = create(:pack, :with_credit, event: event)
      post :virtual_topup, params: new_atts.merge(name: pack.name)
      expect(customer.event.packs.last.catalog_items.last.value).to eq(1.0)
    end
  end

  describe "GET #refunds" do
    before { create_list(:refund, 10, event: event, customer: customer) }

    it "returns a success response" do
      get :refunds, params: atts
      expect(response).to have_http_status(:ok)
    end

    it "returns all refunds" do
      get :refunds, params: atts
      expect(json.size).to be(10)
    end

    it "returns the refunds as JSON" do
      get :refunds, params: atts
      expect(json.last).to eq(obj_to_json(customer.refunds.last, "RefundSerializer"))
    end
  end

  describe "GET #transactions" do
    before { @transactions = create_list(:credit_transaction, 10, event: event, customer: customer) }

    it "returns a success response" do
      get :transactions, params: atts
      expect(response).to have_http_status(:ok)
    end

    it "returns customer with transactions" do
      get :transactions, params: atts
      expect(json["transactions"].size).to be(10)
    end

    it "returns the transactions as JSON" do
      get :transactions, params: atts
      last_transaction = event.transactions.find(json["transactions"].last["id"])
      expect(json["transactions"].last).to eq(obj_to_json(last_transaction, "TransactionSerializer"))
    end
  end

  describe "GET #index" do
    before { create_list(:customer, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all customers" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return customers from another event" do
      customer.update!(event: create(:event))
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json(customer, "Simple::CustomerSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer as JSON" do
      get :show, params: atts
      expect(json).to eq(obj_to_json(customer, "Full::CustomerSerializer"))
    end

    it "returns customer without transactions" do
      get :transactions, params: atts
      expect(json["transactions"].size).to be(0)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Customer" do
        expect do
          post :create, params: { event_id: event.id, customer: valid_attributes }
        end.to change(Customer, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, customer: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created customer" do
        post :create, params: { event_id: event.id, customer: valid_attributes }
        expect(json["id"]).to eq(Customer.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, customer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { first_name: "new name" } }

      before { customer }

      it "updates the requested customer" do
        expect do
          put :update, params: { event_id: event.id, id: customer.to_param, customer: new_attributes }
        end.to change { customer.reload.first_name }.to("new name")
      end

      it "returns the customer" do
        put :update, params: { event_id: event.id, id: customer.to_param, customer: valid_attributes }
        expect(json["id"]).to eq(customer.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: customer.to_param, customer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { customer }

    it "destroys the requested customer" do
      expect do
        delete :destroy, params: atts
      end.to change(Customer, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: atts
      expect(response).to have_http_status(:ok)
    end
  end
end
