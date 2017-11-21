require "rails_helper"

RSpec.describe Customer, type: :model do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe 'validations on' do
    describe "#email" do
      context "of registered customers" do
        before { customer.update!(anonymous: false) }

        it "must be present" do
          customer.email = nil
          expect(customer).not_to be_valid
          expect(customer.errors[:email]).to include("can't be blank")
        end

        it "must be formatted correctly" do
          customer.email = "invalid_email"
          expect(customer).not_to be_valid
          expect(customer.errors[:email]).to include("is invalid")
        end

        it "must be unique within its event" do
          customer2 = build(:customer, event: event, email: customer.email)
          expect(customer2).not_to be_valid
          expect(customer2.errors[:email]).to include("has already been taken")
        end

        it "can be the same as another customer in another event" do
          customer2 = build(:customer, email: customer.email)
          expect(customer2).to be_valid
        end
      end

      context "of anonymous customers" do
        before { customer.update!(anonymous: true) }

        it "can be blank" do
          customer.email = nil
          expect(customer).to be_valid
        end

        it "can be present" do
          customer.email = "a@b.com"
          expect(customer).to be_valid
        end

        it "if present, it must be formatted properly" do
          customer.email = "invalid_email"
          expect(customer).not_to be_valid
          expect(customer.errors[:email]).to include("is invalid")
        end

        it "if present, it must be unique within its event" do
          customer2 = build(:customer, event: event, email: customer.email, anonymous: true)
          expect(customer2).not_to be_valid
          expect(customer2.errors[:email]).to include("has already been taken")
        end

        it "if present, it can be the same as customers in other events" do
          customer2 = build(:customer, email: customer.email, anonymous: true)
          expect(customer2).to be_valid
        end
      end
    end

    describe "#password" do
      context "of registered customers" do
        before { customer.update!(anonymous: false) }

        it "must be longer than 7 characters" do
          customer.password = "aaa"
          expect(customer).not_to be_valid
          expect(customer.errors[:password]).to include("is too short (minimum is 7 characters)")
        end

        it "must be present" do
          customer.password = nil
          expect(customer).not_to be_valid
          expect(customer.errors[:password]).to include("can't be blank")
        end

        it "must be confirmed" do
          customer.password = "foobarbaz"
          customer.password_confirmation = nil
          expect(customer).not_to be_valid
          expect(customer.errors[:password_confirmation]).to include("can't be blank")
        end
      end

      context "of anonymous customers" do
        before { customer.update!(anonymous: true) }

        it "can be blank" do
          customer.password = nil
          expect(customer).to be_valid
        end

        it "is not confirmed" do
          customer.password = "foobarbaz"
          customer.password_confirmation = nil
          expect(customer).to be_valid
        end
      end
    end
  end

  describe ".claim" do
    let(:anon_customer) { create(:customer, event: event, anonymous: true) }

    it "returns false if anon_customer is nil" do
      expect(Customer.claim(event, customer.id, nil)).to be_falsey
    end

    it "returns false if customer is nil" do
      expect(Customer.claim(event, nil, anon_customer.id)).to be_falsey
    end

    it "returns true if anon_customer is self" do
      expect(Customer.claim(event, customer.id, anon_customer.id)).to be_truthy
    end

    it "deletes anon_customer" do
      expect { Customer.claim(event, customer.id, anon_customer.id) }.to change(Customer, :count).by(1)
    end

    it "raises alert if anon_customer is not anonymous" do
      expect(Alert).to receive(:propagate).once
      anon_customer.update! anonymous: false
      Customer.claim(event, customer.id, anon_customer.id)
    end

    it "moves transactions over from anon_customer" do
      t = create(:credit_transaction, customer: anon_customer, event: event)
      expect { Customer.claim(event, customer.id, anon_customer.id) }.to change { t.reload.customer }.from(anon_customer).to(customer)
    end

    it "moves gtags over from anon_customer" do
      gtag = create(:gtag, customer: anon_customer, event: event)
      expect { Customer.claim(event, customer.id, anon_customer.id) }.to change { gtag.reload.customer }.from(anon_customer).to(customer)
    end

    it "moves tickets over from anon_customer" do
      ticket = create(:ticket, customer: anon_customer, event: event)
      expect { Customer.claim(event, customer.id, anon_customer.id) }.to change { ticket.reload.customer }.from(anon_customer).to(customer)
    end
  end

  describe ".build_order" do
    before do
      @station = create(:station, category: "customer_portal", event: event)
      @accesses = create_list(:access, 2, event: event)
      @items = @accesses.map do |item|
        num = rand(10..100)
        @station.station_catalog_items.create!(catalog_item: item, price: num)
        [item.id, 11]
      end
      @order = customer.build_order(@items)
      expect(@order.save).to be_truthy
    end

    describe "when creating refunds" do
      before { @items = [[@accesses.first.id, -11], [@accesses.first.id, -5]] }

      it "creates order_items with negative total" do
        expect(customer.build_order(@items).order_items.map(&:total).sum).to be_negative
      end

      it "creates order_items with negative amount" do
        expect(customer.build_order(@items).order_items.map(&:amount).sum).to be_negative
      end
    end

    it "creates a valid order" do
      expect(@order).to be_valid
    end

    it "allows for extra atts" do
      order = customer.build_order(@items, ip: "127.0.0.1")
      expect(order.ip).to eq("127.0.0.1")
    end

    describe "creates order_items" do
      before { @order_items = @order.order_items }

      it "which are valid" do
        expect(@order_items).not_to be_empty
        @order_items.each { |oi| expect(oi).to be_valid }
      end

      it "with correct price" do
        @order_items.each do |order_item|
          catalog_item = order_item.catalog_item
          expect(order_item.total).to eq(catalog_item.price * 11)
        end
      end

      it "with non price" do
        item = create(:user_flag, event: event)
        @station.station_catalog_items.create!(catalog_item: item, price: 1)
        order = customer.build_order([[item.id, 1]])

        order.order_items.each do |order_item|
          catalog_item = order_item.catalog_item
          expect(order_item.total).to eq(catalog_item.price * 1)
        end
      end

      it "with correct counters" do
        expect(@order_items.map(&:counter).sort).to eq([1, 2])
      end
    end

    describe "on a second run" do
      before do
        @items = @accesses.map { |item| [item.id, 11] }
        @order = customer.build_order(@items)
      end

      it "should add counters" do
        expect(@order.order_items.map(&:counter).sort).to eq([3, 4])
      end
    end
  end

  describe "balance" do
    let(:gtag) { create(:gtag, customer: customer, event: event, active: true) }

    describe ".global_credits" do
      it "takes into account the gtag balance" do
        transactions = create_list(:credit_transaction, 3, gtag: gtag, event: event, action: "sale")
        gtag.recalculate_balance
        expect(customer.global_credits).to eq(transactions.map(&:credits).sum)
      end

      it "does not take into account record_credit transactions" do
        sale_transactions = create_list(:credit_transaction, 3, gtag: gtag, event: event, action: "sale").map(&:credits).sum
        create_list(:credit_transaction, 3, gtag: gtag, event: event, action: "record_credit")
        gtag.recalculate_balance
        expect(customer.global_credits).to eq(sale_transactions)
      end

      it "takes into account orders completed" do
        orders = create_list(:order, 3, customer: customer, status: "completed", event: event).map(&:credits).sum
        expect(customer.global_credits).to eq(orders)
      end

      it "takes into account the refunds made" do
      end
    end

    describe ".global_refundable_credits" do
      it "takes into account the gtag balance" do
        transactions = create_list(:credit_transaction, 3, gtag: gtag, event: event, action: "sale")
        gtag.recalculate_balance
        expect(customer.global_refundable_credits).to eq(transactions.map(&:refundable_credits).sum)
      end

      it "does not take into account record_credit transactions" do
        sale_transactions = create_list(:credit_transaction, 3, gtag: gtag, event: event, action: "sale").map(&:refundable_credits).sum
        create_list(:credit_transaction, 3, gtag: gtag, event: event, action: "record_credit")
        gtag.recalculate_balance
        expect(customer.global_refundable_credits).to eq(sale_transactions)
      end

      it "takes into account orders completed" do
        orders = create_list(:order, 3, customer: customer, status: "completed", event: event).map(&:credits).sum
        expect(customer.global_refundable_credits).to eq(orders)
      end
    end
  end

  describe ".name" do
    it "return the first_name and last_name together if customer is not anonymous" do
      customer.anonymous = false
      allow(customer).to receive(:first_name).and_return("Glownet")
      allow(customer).to receive(:last_name).and_return("Test")
      expect(customer.name).to eq("Glownet Test")
    end

    it "return the first_name and last_name together if customer anonymous" do
      customer.anonymous = true
      allow(customer).to receive(:first_name).and_return(nil)
      allow(customer).to receive(:last_name).and_return(nil)
      expect(customer.name).to eq("Anonymous customer")
    end
  end

  describe ".full_email" do
    it "return the email if customer is not anonymous" do
      customer.anonymous = false
      allow(customer).to receive(:email).and_return("email@glownet.com")
      expect(customer.full_email).to eq("email@glownet.com")
    end

    it "return the anonymous email if customer is anonymous" do
      customer.anonymous = true
      allow(customer).to receive(:email).and_return(nil)
      expect(customer.full_email).to eq("Anonymous email")
    end
  end

  context "with a new customer" do
    describe "the phone" do
      it "is not required" do
        customer = Customer.new(phone: "+34660660660")
        customer.valid?
        expect(customer.errors[:phone]).to eq([])
      end
    end

    describe "the email" do
      %w[customer.foo.com customer@test _@test.].each do |wrong_mail|
        it "is invalid if resembles #{wrong_mail}" do
          customer.email = wrong_mail
        end
      end
    end

    describe "the birthdate" do
      it "is a date" do
        expect(customer.birthdate.is_a?(ActiveSupport::TimeWithZone)).to eq(true)
      end
    end
  end
end
