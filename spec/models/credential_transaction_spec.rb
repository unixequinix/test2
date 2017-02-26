require "spec_helper"

RSpec.describe CredentialTransaction, type: :model do
  subject { build(:credential_transaction) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".description" do
    it "returns the transaction type humanized" do
      expect(subject.description).to eq(subject.action.humanize)
    end
  end
end
