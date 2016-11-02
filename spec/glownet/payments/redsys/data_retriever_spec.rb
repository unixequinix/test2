require "rails_helper"

RSpec.describe Payments::Redsys::DataRetriever, type: :domain_logic do
  let(:number) { rand(10_000_000) }
  let(:order) { create(:order_with_items, number: number) }
  let(:profile) { order.profile }
  let(:event) { profile.event }
  let(:redsys_data_retriever) do
    Seeder::SeedLoader.load_default_event_parameters(event)
    Payments::Redsys::DataRetriever.new(event, order)
  end

  describe "redsys_data_retriever initializer" do
    it "returns a new instance with the instance variables initialized and the form url" do
      expect(redsys_data_retriever.instance_variable_get(:@current_event)).not_to be_nil
      expect(redsys_data_retriever.instance_variable_get(:@order)).not_to be_nil
      expect(redsys_data_retriever.instance_variable_get(:@payment_parameters)).not_to be_nil
    end

    it "returns the value of the name parameter" do
      expect(redsys_data_retriever.name).to eq("Live Nation Esp SAU")
    end

    it "returns the value of the form parameter" do
      expect(redsys_data_retriever.form).to eq("https://sis-t.redsys.es:25443/sis/realizarPago")
    end

    it "returns the value of the code parameter" do
      expect(redsys_data_retriever.code).to eq("126327360")
    end

    it "returns the value of the terminal parameter" do
      expect(redsys_data_retriever.terminal).to eq("6")
    end

    it "returns the value of the currency parameter" do
      expect(redsys_data_retriever.currency).to eq("978")
    end

    it "returns the value of the transaction_type parameter" do
      expect(redsys_data_retriever.transaction_type).to eq("0")
    end

    it "returns the value of the password parameter" do
      expect(redsys_data_retriever.password).to eq("sq7HjrUOBfKmC576ILgskD5srU870gJ7")
    end

    it "returns the total amount of all the order items attached to the order" do
      # prices of every item is in the orders.rb file. In after build section
      expect(redsys_data_retriever.amount).to eq((order.total * 100).floor)
    end

    it "returns the payment method attached to redsys" do
      expect(redsys_data_retriever.pay_methods).to eq("0")
    end

    it "returns the name of the current event" do
      expect(redsys_data_retriever.product_description.length).to be >= 3
    end

    it "returns the name the customer" do
      expect(redsys_data_retriever.client_name.length).to be >= 3
    end

    it "returns the url for redsys notification" do
      url = redsys_data_retriever.notification_url
      uri = URI.parse(url)
      expect(%w(http https).include?(uri.scheme)).to be(true)
    end

    it "returns the signature in uppercase" do
      expect(redsys_data_retriever.signature).to match(%r([A-Za-z0-9\/=+]{44}))
    end
  end
end
