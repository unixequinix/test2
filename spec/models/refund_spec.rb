require "rails_helper"

RSpec.describe Refund, type: :model do
  let(:event) { build(:event, credit: build(:credit)) }
  subject { build(:refund, event: event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe "bank_account" do
    before { subject.gateway = "bank_account" }

    it "validates field_a" do
      subject.field_a = nil
      expect(subject).not_to be_valid
    end

    it "validates field_b" do
      subject.field_b = nil
      expect(subject).not_to be_valid
    end
  end

  describe ".complete!" do
    let(:credit) { create(:credit, value: 10) }
    let(:event) { create(:event) }
    let(:customer) { create(:customer, event: event) }
    let(:customer_portal) { create(:station, event: event, category: "customer_portal", name: "customer_portal") }
    subject { create(:refund, event: event, customer: customer, gateway: "bank_account") }

    before do
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

    it "creates a refunded order" do
      expect { subject.complete! }.to change(event.orders.where(status: "refunded"), :count).by(1)
    end

    it "creates a money transaction" do
      expect { subject.complete! }.to change(event.transactions.money, :count).by(1)
    end

    it "sends an email" do
      email = OrderMailer.completed_refund(subject)
      expect(OrderMailer).to receive(:completed_refund).with(subject).twice.and_return(email)
      subject.complete!
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
      expect(subject.amount_money).to eql(subject.amount * 10)
    end

    it "calculates fee" do
      expect(subject.fee_money).to eql(subject.fee * 10)
    end

    it "calculates total" do
      expect(subject.total_money).to eql(subject.total * 10)
    end
  end

  describe ".correct_iban_and_swift" do
    it "works with a valid iban" do
      subject.field_a = "ES80 2310 0001 1800 0001 2345"
      expect { subject.correct_iban_and_swift }.not_to(change { subject.errors[:field_a] })
    end

    it "checks iban length" do
      subject.field_a = "AA"
      expect { subject.correct_iban_and_swift }.to change { subject.errors[:field_a] }.from([]).to(["Too short"])
    end

    it "checks iban country code and check digits" do
      subject.field_a = "ZZ111111111111"
      expect { subject.correct_iban_and_swift }.to change { subject.errors[:field_a] }.from([]).to(["Unknown country code and Bad check digits"])
    end

    it "checks swift length and format" do
      subject.field_b = "BBVAESMMRELL"
      expect { subject.correct_iban_and_swift }.to change { subject.errors[:field_b] }.from([]).to(["Too long and Bad format"])
    end

    it "works with a valid swift code" do
      subject.field_b = "BBVAESMMREL"
      expect { subject.correct_iban_and_swift }.not_to(change { subject.errors[:field_b] })
    end
  end

  describe ".extra_params_fields" do
    let(:event) { create(:event) }
    subject { build(:refund, event: event, gateway: 'bank_account') }

    before(:each) do
      @payment_gateway = create(:payment_gateway, event: event, extra_fields: ['extra_param_1'])
    end

    it "works with a valid field" do
      subject.extra_params = { extra_param_1: "ES80 2310 0001 1800 0001 2345" }
      expect { subject.extra_params_fields }.not_to(change { subject.errors[:extra_params] })
    end

    it "checks field exists" do
      subject.extra_params = { extra_param_2: "ES80 2310 0001 1800 0001 2345" }
      expect { subject.extra_params_fields }.to change { subject.errors[:extra_params] }.from([]).to(["Field extra_param_1 not found"])
    end

    it "checks field is empty" do
      subject.extra_params = { extra_param_1: "" }
      expect { subject.extra_params_fields }.to change { subject.errors[:extra_params] }.from([]).to(["Field extra_param_1 not found"])
    end

    it "checks field is nil" do
      subject.extra_params = { extra_param_1: nil }
      expect { subject.extra_params_fields }.to change { subject.errors[:extra_params] }.from([]).to(["Field extra_param_1 not found"])
    end
  end

  describe ".prepare_for_bank_account" do
    let(:event) { create(:event) }
    let(:payment_gateway) { create(:payment_gateway, event: event, extra_fields: ['extra_param_1']) }
    subject { build(:refund, event: event, gateway: 'bank_account') }

    it "removes empty spaces on field a" do
      subject.field_a = "ES80 2310 0001 1800 0001 2345"
      subject.prepare_for_bank_account(subject.attributes.symbolize_keys)
      expect(subject.field_a).to eq("ES8023100001180000012345")
    end

    it "removes empty spaces on field b" do
      subject.field_b = "1800 0001 2345"
      subject.prepare_for_bank_account(subject.attributes.symbolize_keys)
      expect(subject.field_b).to eq("180000012345")
    end

    it "removes empty spaces on extra fields" do
      subject.extra_params = { extra_param_1: "extra field number one" }
      subject.prepare_for_bank_account(subject.attributes.symbolize_keys)
      expect(subject.extra_params["extra_param_1"]).to eq("extrafieldnumberone")
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
