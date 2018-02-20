require "rails_helper"

RSpec.describe Refund, type: :model do
  let(:event) { build(:event, credit: build(:credit)) }
  let(:customer) { create(:customer, event: event, anonymous: false) }
  let(:gtag) { create(:gtag, customer: customer, event: event, active: true) }

  subject { build(:refund, event: event, customer: customer, amount: 10, fee: 1) }

  describe "The factory" do
    before do
      gtag.update!(credits: 150)
    end

    it "is a valid factory" do
      expect(subject).to be_valid
    end
  end

  describe ".complete!" do
    let(:credit) { create(:credit, value: 10) }
    let(:event) { create(:event) }
    let(:customer) { create(:customer, event: event, anonymous: false) }
    let(:gtag) { create(:gtag, customer: customer, event: event, active: true) }
    let(:customer_portal) { create(:station, event: event, category: "customer_portal", name: "customer_portal") }
    subject { create(:refund, event: event, customer: customer, gateway: "bank_account") }

    before do
      gtag.update!(credits: 150)
      event.credit = credit
      credit.station_catalog_items.create! station: customer_portal, price: "100"
    end

    it "completes the order" do
      expect(subject).not_to be_completed
      subject.complete!
      expect(subject).to be_completed
    end

    it "works with no refund data" do
      expect { subject.complete! }.not_to raise_error
    end

    it "creates a money transaction" do
      expect { subject.complete! }.to change(event.transactions.money, :count).by(1)
    end

    it "creates a money transaction with negative price" do
      expect { subject.complete! }.to change(event.transactions.money, :count).by(1)
      expect(customer.transactions.money.last.price).to eq(-subject.total_money)
    end

    it "creates a credit transaction" do
      expect { subject.complete! }.to change(event.transactions.credit, :count).by(1)
    end

    it "creates a credit transaction with negative amount" do
      expect { subject.complete! }.to change(event.transactions.credit, :count).by(1)
      expect(customer.transactions.credit.last.payments[event.credit.id.to_s]["amount"].to_f).to eq(-subject.amount.to_f)
    end

    it "sends an email" do
      email = OrderMailer.completed_refund(subject)
      expect(OrderMailer).to receive(:completed_refund).with(subject).twice.and_return(email)
      subject.complete!(true)
    end
  end

  describe ".cancel!" do
    let(:credit) { create(:credit, value: 10) }
    let(:event) { create(:event) }
    let(:customer) { create(:customer, event: event, anonymous: false) }
    let(:gtag) { create(:gtag, customer: customer, event: event, active: true) }
    let(:customer_portal) { create(:station, event: event, category: "customer_portal", name: "customer_portal") }
    subject { create(:refund, event: event, customer: customer, gateway: "bank_account") }

    before do
      gtag.update!(credits: 150)
      event.credit = credit
      credit.station_catalog_items.create! station: customer_portal, price: "100"
    end

    it "cancels the order" do
      expect(subject).not_to be_cancelled
      subject.cancel!
      expect(subject).to be_cancelled
    end

    it "creates a money transaction" do
      expect { subject.cancel! }.to change(event.transactions.money, :count).by(1)
    end

    it "creates a money transaction with positive price" do
      expect { subject.cancel! }.to change(event.transactions.money, :count).by(1)
      expect(customer.transactions.money.last.price).to eq(subject.total_money)
    end

    it "creates a credit transaction" do
      expect { subject.cancel! }.to change(event.transactions.credit, :count).by(1)
    end

    it "creates a credit transaction with positive amount" do
      expect { subject.cancel! }.to change(event.transactions.credit, :count).by(1)
      expect(customer.transactions.credit.last.payments[event.credit.id.to_s]["amount"].to_f).to eq(subject.amount.to_f)
    end

    it "sends an email" do
      email = OrderMailer.cancelled_refund(subject)
      expect(OrderMailer).to receive(:cancelled_refund).with(subject).twice.and_return(email)
      subject.cancel!(true)
    end

    it "works when customer balance is 0" do
      subject.update!(amount: 150)
      subject.complete!
      expect { subject.cancel! }.to change { customer.reload.credits }.from(0).to(150)
    end
  end

  describe ".total" do
    it "returns the sum of amount and fee" do
      subject.amount = 10
      subject.fee = 2
      expect(subject.total).to eq(12)
    end
  end

  describe ".number" do
    it "returns always the same size of digits in the refund number" do
      subject.id = 1
      expect(subject.number.size).to eq(7)

      subject.id = 122
      expect(subject.number.size).to eq(7)
    end
  end

  describe "money" do
    before { allow(event.credit).to receive(:value).and_return(10) }

    it "calculates amount" do
      expect(subject.price_money).to eql(subject.amount.to_f * 10)
    end

    it "calculates fee" do
      expect(subject.fee_money).to eql(subject.fee.to_f * 10)
    end

    it "calculates total" do
      expect(subject.total_money).to eql(subject.total.to_f * 10)
    end
  end

  describe ".correct_iban_and_swift" do
    it "works with a valid iban" do
      subject.fields[:iban] = "ES80 2310 0001 1800 0001 2345"
      expect { subject.correct_iban_and_swift }.not_to(change { subject.errors[:iban] })
    end

    it "checks iban length" do
      subject.fields[:iban] = "AA"
      expect { subject.correct_iban_and_swift }.to change { subject.errors[:iban] }.from([]).to(["Too short"])
    end

    it "checks iban country code and check digits" do
      subject.fields[:iban] = "ZZ111111111111"
      expect { subject.correct_iban_and_swift }.to change { subject.errors[:iban] }.from([]).to(["Unknown country code and Bad check digits"])
    end

    it "checks swift length and format" do
      subject.fields[:swift] = "BBVAESMMRELL"
      expect { subject.correct_iban_and_swift }.to change { subject.errors[:swift] }.from([]).to(["Too long and Bad format"])
    end

    it "works with a valid swift code" do
      subject.fields[:swift] = "BBVAESMMREL"
      expect { subject.correct_iban_and_swift }.not_to(change { subject.errors[:swift] })
    end
  end

  describe ".fields" do
    let(:event) { create(:event, refund_fields: ['extra_param_1']) }
    subject { build(:refund, event: event, gateway: 'bank_account') }

    it "works with a valid field" do
      subject.fields = { extra_param_1: "ES80 2310 0001 1800 0001 2345" }
      expect { subject.extra_params_fields }.not_to(change { subject.errors[:fields] })
    end

    it "checks field exists" do
      subject.fields = { extra_param_2: "ES80 2310 0001 1800 0001 2345" }
      expect { subject.extra_params_fields }.to change { subject.errors[:fields] }.from([]).to(["Field extra_param_1 not found"])
    end

    it "checks field is empty" do
      subject.fields = { extra_param_1: "" }
      expect { subject.extra_params_fields }.to change { subject.errors[:fields] }.from([]).to(["Field extra_param_1 not found"])
    end

    it "checks field is nil" do
      subject.fields = { extra_param_1: nil }
      expect { subject.extra_params_fields }.to change { subject.errors[:fields] }.from([]).to(["Field extra_param_1 not found"])
    end
  end

  describe ".prepare_for_bank_account" do
    let(:event) { create(:event) }
    subject { build(:refund, event: event, gateway: 'bank_account') }

    it "removes empty spaces on extra fields" do
      subject.fields = { extra_param_1: "extra field number one" }
      subject.prepare_for_bank_account(subject.attributes.symbolize_keys)
      expect(subject.fields["extra_param_1"]).to eq("extrafieldnumberone")
    end

    context "iban and bsb don't exist" do
      it "checks iban field does not exists" do
        subject.prepare_for_bank_account(subject.attributes.symbolize_keys)
        expect(subject.iban).to be(nil)
      end

      it "checks bsb field does not exists" do
        subject.prepare_for_bank_account(subject.attributes.symbolize_keys)
        expect(subject.iban).to be(nil)
      end
    end

    context "iban and bsb exist" do
      before(:each) do
        subject.iban = true
        subject.bsb = true
      end

      it "checks iban field does not exists" do
        subject.prepare_for_bank_account(subject.attributes.symbolize_keys)
        expect(subject.iban).to be(true)
      end

      it "checks bsb field does not exists" do
        subject.prepare_for_bank_account(subject.attributes.symbolize_keys)
        expect(subject.iban).to be(true)
      end
    end
  end
end
