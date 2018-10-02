require 'rails_helper'

shared_examples_for "creditable" do
  let(:model) { described_class } # the class that includes the concern
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  subject { create(model.to_s.underscore.to_sym, event: event) }

  describe ".number" do
    it "returns always the same size of digits in the order number" do
      subject.id = 1
      expect(subject.number.size).to eq(7)

      subject.id = 122
      expect(subject.number.size).to eq(7)
    end
  end

  describe "money" do
    it ".money_total returns money base plus fee" do
      allow(subject).to receive(:money_base).and_return(5)
      allow(subject).to receive(:money_fee).and_return(5)
      expect(subject.money_total).to eq(10.00)
    end
  end

  describe "credit" do
    it ".credit_total returns credit base plus fee" do
      allow(subject).to receive(:credit_base).and_return(5)
      allow(subject).to receive(:credit_fee).and_return(5)
      expect(subject.credit_total).to eq(10.00)
    end
  end
end

RSpec.describe Order, type: :model do
  it_behaves_like "creditable"
end

RSpec.describe Refund, type: :model do
  it_behaves_like "creditable"
end
