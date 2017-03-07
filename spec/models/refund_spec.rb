require "spec_helper"

RSpec.describe Refund, type: :model do
  let(:event) { build(:event, credit: build(:credit)) }
  subject { build(:refund, event: event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "validates field_a" do
    subject.field_a = nil
    expect(subject).not_to be_valid
  end

  it "validates field_b" do
    subject.field_b = nil
    expect(subject).not_to be_valid
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
      expect { subject.correct_iban_and_swift }.not_to change { subject.errors[:field_a] }
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
      expect { subject.correct_iban_and_swift }.not_to change { subject.errors[:field_b] }
    end
  end
end
