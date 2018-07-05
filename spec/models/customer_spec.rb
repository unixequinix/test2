require "rails_helper"

RSpec.describe Customer, type: :model do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe 'validations on' do
    describe "#email" do
      context "of registered customers" do
        before do
          customer.update!(anonymous: false)
        end

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
          customer2 = build(:customer, event: event, email: customer.email, anonymous: false)
          expect(customer2).not_to be_valid
          expect(customer2.errors[:email]).to include("has already been taken")
        end

        it "must be not be unique with other events" do
          customer2 = build(:customer, email: customer.email, anonymous: false)
          expect(customer2).to be_valid
        end

        it "can be the same as another customer in another event" do
          customer2 = build(:customer, email: customer.email)
          expect(customer2).to be_valid
        end
      end

      context "of anonymous customers" do
        before { customer.update!(anonymous: true) }

        it "email can be blank" do
          customer.email = nil
          expect(customer).to be_valid
        end

        it "must be not unique within its event" do
          customer2 = build(:customer, event: event)
          expect(customer2).to be_valid
        end

        it "must be not unique with other events" do
          customer2 = build(:customer)
          expect(customer2).to be_valid
        end
      end
    end

    describe "#password" do
      context "of registered customers" do
        before { customer.update!(anonymous: false) }

        it "must be longer than 7 characters" do
          customer.password = "Aa4"
          customer.password_confirmation = "Aa4"
          expect(customer).not_to be_valid
          expect(customer.errors[:password]).to include("is too short (minimum is 7 characters)")
        end

        it "must include at least one lowercase letter and one digit" do
          customer.password = "glownet"
          customer.password_confirmation = "glownet"
          expect(customer).not_to be_valid
          expect(customer.errors[:password]).to include("must include 1 lowercase letter and 1 digit")
        end

        it "is valid password" do
          customer.password = "gl0wn3T"
          customer.password_confirmation = "gl0wn3T"
          expect(customer).to be_valid
        end

        it "must be present" do
          customer.password = ""
          customer.password_confirmation = ""
          expect(customer).not_to be_valid
          expect(customer.errors[:password]).to include("can't be blank")
        end

        it "must be confirmed" do
          customer.password = "foobarbaz"
          customer.password_confirmation = ""
          expect(customer).not_to be_valid
          expect(customer.errors[:password_confirmation]).to include("doesn't match Password")
        end
      end

      context "of anonymous customers" do
        before { customer.update!(anonymous: true) }

        it "can be blank" do
          customer.password = nil
          expect(customer).to be_valid
        end

        it "is not confirmed" do
          customer.password = "Gl0wn3T"
          customer.password_confirmation = nil
          expect(customer).to be_valid
        end
      end
    end
  end

  describe ".claim" do
    let(:anon_customer) { create(:customer, event: event, anonymous: true) }

    it "returns false if customer is nil" do
      expect(Customer.claim(event, nil, anon_customer)).to be_falsey
    end

    it "returns customer if anon_customer is self" do
      expect(Customer.claim(event, customer, anon_customer)).to eq(customer)
    end

    it "deletes anon_customer" do
      expect { Customer.claim(event, customer, anon_customer) }.to change(Customer, :count).by(1)
    end

    it "raises alert if anon_customer is not anonymous" do
      expect(Alert).to receive(:propagate).once
      anon_customer.update!(anonymous: false)
      Customer.claim(event, customer, anon_customer)
    end

    it "moves transactions over from anon_customer" do
      t = create(:credit_transaction, customer: anon_customer, event: event)
      expect { Customer.claim(event, customer, anon_customer) }.to change { t.reload.customer }.from(anon_customer).to(customer)
    end

    it "moves gtags over from anon_customer" do
      gtag = create(:gtag, customer: anon_customer, event: event)
      expect { Customer.claim(event, customer, anon_customer) }.to change { gtag.reload.customer }.from(anon_customer).to(customer)
    end

    it "moves tickets over from anon_customer" do
      ticket = create(:ticket, customer: anon_customer, event: event)
      expect { Customer.claim(event, customer, anon_customer) }.to change { ticket.reload.customer }.from(anon_customer).to(customer)
    end
  end

  describe ".build_order" do
    before do
      accesses = create_list(:access, 2, event: event)
      @accesses = accesses.map { |item| [item.id, rand(100)] }
      @credits = event.credits.map { |item| [item.id, 100] }
      @order = customer.build_order(@accesses + @credits)
      expect(@order.save).to be_truthy
    end

    it "creates a valid order" do
      expect(@order).to be_valid
    end

    it "allows for extra atts" do
      order = customer.build_order(@accesses, ip: "127.0.0.1")
      expect(order.ip).to eq("127.0.0.1")
    end

    describe "calculating credits" do
      before { @pack = create(:pack, :with_credits, event: event) }

      it "adds the credits as to order" do
        expect(@order.credits).to eq(100)
      end

      it "adds the virtual_credits as to order" do
        expect(@order.virtual_credits).to eq(100)
      end

      it "accounts for pack credits" do
        expect(@pack.credits).not_to be_zero
        expect(customer.build_order([[@pack.id, 10]] + @credits + @accesses).credits).to eq((@pack.credits * 10) + 100)
      end

      it "accounts for pack virtual_credits" do
        expect(@pack.credits).not_to be_zero
        expect(customer.build_order([[@pack.id, 10]] + @credits + @accesses).virtual_credits).to eq((@pack.virtual_credits * 10) + 100)
      end
    end

    describe "creates order_items" do
      before { @order_items = @order.order_items }

      it "which are valid" do
        expect(@order_items).not_to be_empty
        @order_items.each { |oi| expect(oi).to be_valid }
      end

      it "with correct counters" do
        expect(@order_items.map(&:counter).sort).to eq([1, 2, 3, 4])
      end
    end

    describe "on a second run" do
      before do
        @order = customer.build_order(@accesses)
      end

      it "should add counters" do
        expect(@order.order_items.map(&:counter).sort).to eq([5, 6])
      end
    end
  end

  describe "balance" do
    let(:gtag) { create(:gtag, customer: customer, event: event, active: true) }

    describe ".credits" do
      it "takes into account the gtag balance" do
        gtag.update!(credits: 12.5)
        expect(customer.credits).to eq(12.5)
      end

      it "takes into account orders completed" do
        total = create_list(:order, 2, customer: customer, status: "completed", event: event).sum(&:credits)
        create(:order, customer: customer, status: "cancelled", event: event)
        expect(customer.credits).to eq(total)
      end

      it "does not takes into account orders refunded" do
        create_list(:order, 2, customer: customer, status: "refunded", event: event)
        total = create_list(:order, 2, customer: customer, status: "completed", event: event).sum(&:credits)
        create(:order, customer: customer, status: "cancelled", event: event)
        expect(customer.credits).to eq(total)
      end

      it "does not take into account redeemed orders" do
        OrderItem.where(order: create_list(:order, 3, customer: customer, status: "completed", event: event)).update_all(redeemed: true)
        expect(customer.credits).to be_zero
      end

      context "with refunds" do
        before { gtag.update!(credits: 50) }

        it "takes into account completed refunds as negative" do
          total = create_list(:refund, 2, customer: customer, status: "completed", event: event).sum(&:credit_total)
          expect(customer.credits).to eq(50 - total)
        end

        it "does not take into account other refunds" do
          create_list(:refund, 2, customer: customer, status: "started", event: event).sum(&:credit_total)
          expect(customer.credits).to eq(50)
        end
      end
    end

    describe ".virtual_credits" do
      it "takes into account the gtag balance" do
        gtag.update!(virtual_credits: 12.5)
        expect(customer.virtual_credits).to eq(12.5)
      end

      it "takes into account orders completed" do
        total = create_list(:order, 3, customer: customer, status: "completed", event: event).sum(&:virtual_credits)
        create(:order, customer: customer, status: "cancelled", event: event)
        expect(customer.virtual_credits).to eq(total)
      end

      it "takes into account orders refunded" do
        total = create_list(:order, 3, customer: customer, status: "refunded", event: event).sum(&:virtual_credits)
        create(:order, customer: customer, status: "cancelled", event: event)
        expect(customer.virtual_credits).to eq(total)
      end

      it "does not take into account redeemed orders" do
        OrderItem.where(order: create_list(:order, 3, customer: customer, status: "completed", event: event)).update_all(redeemed: true)
        expect(customer.virtual_credits).to be_zero
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

  describe ".gdpr_acceptance" do
    it "should have acceptance datetime if gdpr_acceptance is true" do
      customer.gdpr_acceptance = true
      customer.save!
      expect(customer.gdpr_acceptance_at).to_not eql(nil)
    end
  end
end
