RSpec.shared_examples "controller topups" do
  describe "POST #topup" do
    let(:new_atts) { atts.merge(credits: 100, gateway: "paypal") }

    it "returns a success response" do
      post :topup, params: new_atts
      expect(response).to have_http_status(:ok)
    end

    it "returns the order as JSON" do
      post :topup, params: new_atts
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(json).to eq(obj_to_json_v2(order, "OrderSerializer"))
    end

    it "creates an order for the customer" do
      expect { post :topup, params: new_atts }.to change(Order, :count).by(1)
    end

    it "sums to the credits of the customer" do
      post :topup, params: new_atts
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(order.customer.credits.to_f).to eq(100)
    end

    it "sets the price of the order" do
      new_atts[:money_base] = 111
      post :topup, params: new_atts
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(order.money_base).to eq(111)
    end

    it "sets the fee of the order" do
      new_atts[:money_fee] = 11
      post :topup, params: new_atts
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(order.money_fee).to eq(11)
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
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(order.gateway).to eq("somethingcrazy")
    end

    it "dos not send email by default" do
      expect(OrderMailer).not_to receive(:completed_order)
      post :topup, params: new_atts
    end

    it "can send email if requested" do
      fake_order = customer.build_order([[10]])
      fake_order.complete!
      fake_email = OrderMailer.completed_order(fake_order)
      expect(OrderMailer).to receive(:completed_order).twice.and_return(fake_email)
      post :topup, params: new_atts.merge(send_email: true)
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
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(json).to eq(obj_to_json_v2(order, "OrderSerializer"))
    end

    it "creates an order for the customer" do
      expect { post :virtual_topup, params: new_atts }.to change { event.reload.orders.count }.by(1)
    end

    it "sums to the virtual credits of the customer" do
      post :virtual_topup, params: new_atts
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(order.customer.virtual_credits.to_f).to eq(10)
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
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(order.gateway).to eq("somethingcrazy")
    end

    it "sets the order catalog_item to virtual_credit" do
      post :virtual_topup, params: new_atts
      order = event.orders.find(JSON.parse(response.body)["id"])
      expect(order.order_items.last.catalog_item).to eq(event.virtual_credit)
    end

    it "dos not send email by default" do
      expect(OrderMailer).not_to receive(:completed_order)
      post :virtual_topup, params: new_atts
    end

    it "can send email if requested" do
      fake_order = customer.build_order([[10]])
      fake_order.complete!
      fake_email = OrderMailer.completed_order(fake_order)
      expect(OrderMailer).to receive(:completed_order).twice.and_return(fake_email)
      post :virtual_topup, params: new_atts.merge(send_email: true)
    end
  end
end
