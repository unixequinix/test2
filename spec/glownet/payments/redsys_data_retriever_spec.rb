require "rails_helper"

RSpec.describe Payments::RedsysDataRetriever, type: :service do

  before(:all) do
    order = create(:order , number: "2678434012")
    customer_event_profile = order.customer_event_profile
    event = customer_event_profile.event
    Seeder::SeedLoader.load_default_event_parameters(event)
    @redsys_data_retriever = Payments::RedsysDataRetriever.new(event, order)
  end

  describe "redsys_data_retriever initializer" do
    it "returns a new instance with the instance variables initialized" do
      expect(@redsys_data_retriever.instance_variable_get(:@current_event))
        .not_to be_nil
      expect(@redsys_data_retriever.instance_variable_get(:@order))
        .not_to be_nil
      expect(@redsys_data_retriever.instance_variable_get(:@payment_parameters))
        .not_to be_nil
    end
  end

  describe "form" do
    it "returns the value of the form parameter" do
      expect(@redsys_data_retriever.form).to eq("https://sis-t.redsys.es:25443/sis/realizarPago")
    end
  end

  describe "name" do
    it "returns the value of the name parameter" do
      expect(@redsys_data_retriever.name).to eq("Live Nation Esp SAU")
    end
  end

  describe "code" do
    it "returns the value of the code parameter" do
      expect(@redsys_data_retriever.code).to eq("126327360")
    end
  end

  describe "terminal" do
    it "returns the value of the terminal parameter" do
      expect(@redsys_data_retriever.terminal).to eq("6")
    end
  end

  describe "currency" do
    it "returns the value of the currency parameter" do
      expect(@redsys_data_retriever.currency).to eq("978")
    end
  end

  describe "transaction_type" do
    it "returns the value of the transaction_type parameter" do
      expect(@redsys_data_retriever.transaction_type).to eq("0")
    end
  end

  describe "password" do
    it "returns the value of the password parameter" do
      expect(@redsys_data_retriever.password).to eq("qwertyasdf0123456789")
    end
  end

  describe "amount" do
    it "returns the total amount of all the order items attached to the order" do
      #prices of every item is in the orders.rb file. In after build section
      expect(@redsys_data_retriever.amount).to eq(9975)
    end
  end

  describe "pay_methods" do
    it "returns the payment method attached to redsys" do
      expect(@redsys_data_retriever.pay_methods).to eq('0')
    end
  end

  describe "product_description" do
    it "returns the name of the current event" do
      expect(@redsys_data_retriever.product_description.length).to be >= 3
    end
  end

  describe "client_name" do
    it "returns the name the customer" do
      expect(@redsys_data_retriever.client_name.length).to be >= 3
    end
  end

  describe "notification_url" do
    it "returns the url for redsys notification" do
      url = @redsys_data_retriever.notification_url
      uri = URI.parse(url)
      expect(%w(http https).include?(uri.scheme)).to be(true)
    end
  end

  describe "message" do
    it "returns the message for the redsys system" do
      message = ""
      message += "9975"
      message += "2678434012"
      message += "126327360"
      message += "978"
      message += "0"
      message += "http://localhost:3000/"
      message += @redsys_data_retriever.current_event.name
      message += "/payments"
      message += "qwertyasdf0123456789"

      expect(@redsys_data_retriever.message).to eq(message)
    end
  end

  describe "signature" do
    it "returns the signature in uppercase" do
      expect(@redsys_data_retriever.signature).to match(/\A[A-Z0-9]{40}\z/)
    end
  end

end