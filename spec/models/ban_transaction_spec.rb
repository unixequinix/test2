require "rails_helper"

RSpec.describe BanTransaction, type: :model do
  subject { BanTransaction }
  let(:basic_fields) { Transaction.mandatory_fields }

  describe ".mandatory_fields" do
    it "returns the correct fields" do
      expect(subject.mandatory_fields).to eq(basic_fields + %w(message))
    end
  end
end
